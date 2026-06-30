# ML Integration Guide

> On-device machine learning for real-time racing coaching.

## Architecture

```text
Telemetry (25 Hz) → FeatureExtractor (26 features) → ML Model → CueEngine → Audio Coaching
```

Two inference frameworks, coexisting:

| Framework | Role | Model Format | When to Use |
|-----------|------|-------------|-------------|
| **tract** | Pre-trained inference | ONNX | Ship trained models from PyTorch/JAX |
| **burn** | Train + infer in Rust | Native `.mpk` | On-device fine-tuning, personalization |

## Quick Start (tract)

### 1. Train a model (Python)

```python
import torch
import torch.nn as nn

class BrakeNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(26, 64), nn.ReLU(),
            nn.Linear(64, 32), nn.ReLU(),
            nn.Linear(32, 4),
        )

    def forward(self, x):
        return self.net(x)

model = BrakeNet()
# ... train ...
dummy = torch.randn(1, 26)
torch.onnx.export(model, dummy, "brake_model.onnx",
                  input_names=["features"], output_names=["predictions"])
```

### 2. Place the model

```
rust/assets/ml/
└── brake_model.onnx    # ~20 KB for 26→64→32→4
```

### 3. Load and run (Rust)

```rust
use tract::prelude::*;

pub struct BrakePredictor {
    runnable: SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>,
}

impl BrakePredictor {
    pub fn load(onnx_bytes: &[u8]) -> anyhow::Result<Self> {
        let model = tract::onnx()
            .model_for_read(&mut std::io::Cursor::new(onnx_bytes))?
            .into_optimized()?
            .into_runnable()?;
        Ok(Self { runnable: model })
    }

    pub fn predict(&self, features: &[f32; 26]) -> anyhow::Result<[f32; 4]> {
        let input = tract::ndarray::arr1(features)
            .into_shape((1, 26))?
            .into_tensor();
        let result = self.runnable.run(tvec!(input.into()))?;
        let output = result[0].as_slice::<f32>()?;
        Ok([output[0], output[1], output[2], output[3]])
    }
}
```

### 4. Wire into coaching pipeline

Add `MlEngine` to `Session` in `coaching_api.rs`:

```rust
let ml_predictions = session.ml_engine.process(&input);
// Feed into CueEngine — CueType::MlBraking / CueType::MlThrottle already exist
```

## Module Structure

```text
rust/src/ml/
├── mod.rs              # MlEngine — dispatches to sub-modules
├── features.rs         # FeatureExtractor (26 features, already exists)
├── tract_models/       # Pre-trained ONNX models
│   ├── mod.rs
│   └── brake_predictor.rs
└── burn_models/        # (Phase 2) Rust-native models
    ├── mod.rs
    ├── style_classifier.rs
    └── trainer.rs      # On-device fine-tuning
```

## Existing Infrastructure

Already built and tested:

- **`FeatureExtractor`** (`rust/src/ml/features.rs`): Extracts 26 features per frame with sliding window, circular heading stats. 13 unit tests.
- **`CueType::MlBraking`** and **`CueType::MlThrottle`**: Already in the type system. Coaching pipeline is wired for ML cues.
- **Feature vector (26 values)**: For each of 5 linear channels (speed, g_lat, g_lon, g_vert, altitude) — mean, stddev, min, max (20 features). Plus circular heading mean + stddev (2 features), speed range (1), g_lat range (1), g_lon range (1), g_total mean (1).

---

## Adding burn (Phase 2)

When you need on-device training, fine-tuning, or personalization.

### Step 1: Add dependency

```diff
 # rust/Cargo.toml
 [dependencies]
 tract = "0.23"
+burn = { version = "0.21", default-features = false, features = ["flex"] }
```

### Step 2: Create burn_models/

```rust
// rust/src/ml/burn_models/style_classifier.rs
use burn::prelude::*;
use burn::nn::{Linear, LinearConfig};

#[derive(Module, Debug)]
pub struct StyleClassifier<B: Backend> {
    linear1: Linear<B>,  // 26 → 32
    linear2: Linear<B>,  // 32 → 16
    output: Linear<B>,   // 16 → 4
}

impl<B: Backend> StyleClassifier<B> {
    pub fn new(device: &B::Device) -> Self {
        Self {
            linear1: LinearConfig::new(26, 32).init(device),
            linear2: LinearConfig::new(32, 16).init(device),
            output: LinearConfig::new(16, 4).init(device),
        }
    }

    pub fn predict(&self, features: Tensor<B, 2>) -> Tensor<B, 2> {
        let x = self.linear1.forward(features).relu();
        let x = self.linear2.forward(x).relu();
        self.output.forward(x)
    }
}
```

### Step 3: Add to MlEngine

```rust
// rust/src/ml/mod.rs — just add a field, tract code untouched
use burn::backend::Flex;

pub struct MlEngine {
    feature_extractor: FeatureExtractor,
    brake_predictor: Option<tract_models::BrakePredictor>,      // tract (unchanged)
    style_classifier: Option<burn_models::StyleClassifier<Flex>>, // burn (new)
}
```

### Step 4: On-device fine-tuning (optional)

```rust
// Pseudocode — called between sessions, not in the 25 Hz loop.
// See burn docs for full training API: https://burn.dev/book/
pub fn fine_tune(
    model: StyleClassifier<Flex>,
    session_data: Vec<LabeledFrame>,
    epochs: usize,
) -> StyleClassifier<Flex> {
    let device = Default::default();
    let optim = AdamConfig::new().init();
    let batcher = FrameBatcher::new(session_data);

    for epoch in 0..epochs {
        for batch in batcher.iter() {
            let loss = model.forward_loss(batch);
            // Backprop + optimizer step via burn's autodiff backend
        }
    }

    // Save personalized weights (~6 KB for this model)
    CompactRecorder::new()
        .record(model.clone().into_record(), "personalized_weights");

    model
}
```

### Personalized weight storage

```text
{app_documents}/ml/
├── style_classifier_base.mpk                          # Shipped with app
├── style_classifier_{driver}_{car}_{track}.mpk        # Fine-tuned on-device
```

**Zero changes to tract code. Both frameworks coexist.**

---

## Binary Size Budget

| Component | Size |
|-----------|------|
| tract | ~0.8–1.5 MB |
| burn (flex backend) | ~1.5–2.5 MB |
| Both together | ~2.5–3.5 MB |
| ONNX model (26→64→32→4) | ~20 KB |
| burn weights (.mpk, f16) | ~6 KB |

For context: Flutter engine is ~10 MB. ML adds ~30%.

## Feature Flags (Optional)

```toml
[features]
default = ["ml-tract"]
ml-tract = ["dep:tract"]
ml-burn = ["dep:burn"]
```

```rust
#[cfg(feature = "ml-tract")]
mod tract_models;

#[cfg(feature = "ml-burn")]
mod burn_models;
```

---

## On-Device LLMs (Phase 3)

For natural language post-session coaching (NOT the 25 Hz loop):

| Platform | Model | Bundled? |
|----------|-------|----------|
| Android | Gemini Nano (AICore) | No — system-managed |
| iOS 26+ | Apple Foundation Models | No — system-managed |
| Fallback | llama.cpp via `llama-cpp-4` | Yes (~2 GB download) |

Architecture: async post-lap/post-session analysis, separate from the real-time inference path.

---

## Roadmap

### Phase 0: Infrastructure (done)

- [x] `FeatureExtractor` — 26-feature sliding window, 13 unit tests
- [x] `CueType::MlBraking` and `CueType::MlThrottle` — wired into coaching pipeline
- [x] Analyzer configs — `ml_features` stub in `AnalysisConfig`

### Phase 1: Data Collection (next)

No trained model exists yet. Before adding an inference framework, we need
labeled training data.

**What to collect during sessions:**

| Event | Label | Source |
|-------|-------|--------|
| Braking onset | track position + speed + G at brake application | `BrakingOnsetDetector` |
| Throttle application | track position + speed + G at throttle-on | New: `ThrottleOnsetDetector` |
| Reference comparison | delta vs reference at each event | `ReferenceLap` |
| Corner classification | apex position + radius + entry/exit speed | GPS + speed trace |

**Storage:** Append labeled events to a per-session `.jsonl` file alongside raw telemetry.
After 5-10 sessions, export to training pipeline.

### Phase 2: First ML Model

1. Train a model (PyTorch or burn) on collected data
2. Add inference framework:
   - **tract** if training in Python (PyTorch → ONNX → tract)
   - **burn** if training in Rust (same codebase, no export step)
3. Wire into `MlEngine` → `CueEngine` for ML-powered coaching cues

See [Quick Start (tract)](#quick-start-tract) and [Adding burn](#adding-burn-phase-2)
above for integration details.

### Phase 3: Personalization

- On-device fine-tuning via burn (learn driver/car/track specifics)
- Requires ~50-100 labeled events (3-5 laps of calibration data)

### Phase 4: On-Device LLMs

- Natural language post-session coaching (async, not in the 25 Hz loop)
- Gemini Nano (Android) / Apple Foundation Models (iOS)
- See [On-Device LLMs](#on-device-llms-phase-3) above
