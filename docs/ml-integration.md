# ML Integration Guide

> On-device machine learning for real-time racing coaching.

## Architecture

```
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

Add `MlEngine` to `CoachingSession` in `coaching_api.rs`:

```rust
let ml_predictions = session.ml_engine.process(&input);
// Feed into CueEngine — CueType::MlBraking / CueType::MlThrottle already exist
```

## Module Structure

```
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
- **Feature list**: speed, lateral/longitudinal G, heading rate, brake/throttle inputs, friction circle utilization, rolling statistics (mean, stddev), and more.

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
// Called between sessions, not in the 25 Hz loop
pub fn fine_tune(
    model: StyleClassifier<Flex>,
    session_data: Vec<LabeledFrame>,
) -> StyleClassifier<Flex> {
    // ~5-10 seconds for 1000 frames × 10 epochs
    // Save: CompactRecorder::new().record(model.into_record(), path)
    model
}
```

### Personalized weight storage

```
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

1. **Now**: Add tract, ship first ML coaching cue (brake prediction)
2. **Next**: Add burn alongside tract for personalized models
3. **Later**: On-device LLM for natural language session review
