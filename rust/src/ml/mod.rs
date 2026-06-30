//! ML feature extraction from telemetry windows.
//!
//! Extracts fixed-size feature vectors from sliding windows of telemetry
//! data. These features can be used for:
//!
//! - Braking point prediction (when should the driver brake?)
//! - Driving style classification (aggressive vs smooth)
//! - Anomaly detection (unusual behavior compared to reference)
//!
//! The feature vectors are designed to be fed into TFLite models on-device.

pub mod features;
