//! Race Coach Core — telemetry analysis engine.
//!
//! All computation lives here: distance tracking, braking detection,
//! friction circle analysis, delta-T, coaching cue generation, and
//! ML feature extraction.
//!
//! Called from Flutter via `flutter_rust_bridge`. Dart handles platform
//! concerns (BLE, TTS, UI, Firebase). Rust handles math.

// Allow cfg attributes from flutter_rust_bridge generated code.
#![allow(unexpected_cfgs)]

pub mod api;
pub mod braking;
pub mod calibration;
pub mod coaching;
pub mod distance;
pub mod dynamics;
mod frb_generated; /* AUTO-GENERATED — do not edit */
pub mod generated;
pub mod math;
pub mod ml;
pub mod reference;
pub mod registry;
pub mod timing;
pub mod types;

// Re-exports for convenience
pub use calibration::imu_bias::{apply_bias, ImuCalibrator};
pub use reference::reference_lap::ReferenceLap;
pub use registry::{AnalysisContext, AnalysisRegistry, AnalysisResult, TelemetryAnalyzer};
pub use types::*;
