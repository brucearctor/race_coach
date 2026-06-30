//! Feature extraction for ML models.
//!
//! Computes fixed-size feature vectors from a sliding window of telemetry
//! frames. Features include statistical aggregates (mean, std, min, max)
//! of speed, G-forces, and derived quantities like jerk and grip utilization.
//!
//! Window size: configurable, typically 25 frames (1 second at 25 Hz).
//! Output: flat f32 vector suitable for TFLite inference.

use std::collections::VecDeque;

use crate::types::TelemetryInput;

/// Configuration for feature extraction.
#[derive(Debug, Clone)]
pub struct FeatureConfig {
    /// Number of frames in the sliding window.
    pub window_size: usize,
}

impl Default for FeatureConfig {
    fn default() -> Self {
        Self { window_size: 25 } // 1 second at 25 Hz
    }
}

/// Feature extractor — maintains a sliding window and computes features.
pub struct FeatureExtractor {
    config: FeatureConfig,
    window: VecDeque<TelemetryInput>,
}

/// Number of features produced per extraction.
/// 6 channels × 4 stats (mean, std, min, max) + 2 derived = 26 features.
pub const FEATURE_COUNT: usize = 26;

impl FeatureExtractor {
    pub fn new() -> Self {
        Self::with_config(FeatureConfig::default())
    }

    pub fn with_config(config: FeatureConfig) -> Self {
        Self {
            window: VecDeque::with_capacity(config.window_size),
            config,
        }
    }

    /// Push a frame into the sliding window.
    pub fn push(&mut self, input: TelemetryInput) {
        if self.window.len() >= self.config.window_size {
            self.window.pop_front();
        }
        self.window.push_back(input);
    }

    /// Whether the window is full and ready for extraction.
    pub fn is_ready(&self) -> bool {
        self.window.len() >= self.config.window_size
    }

    /// Extract a feature vector from the current window.
    ///
    /// Returns None if the window is not full yet.
    /// Returns a flat vector of [FEATURE_COUNT] f32 values.
    pub fn extract(&self) -> Option<Vec<f32>> {
        if !self.is_ready() {
            return None;
        }

        let n = self.window.len() as f32;
        let mut features = Vec::with_capacity(FEATURE_COUNT);

        // Extract 6 channels: speed, g_lat, g_long, g_vert, heading, altitude
        let channels: Vec<Vec<f32>> = vec![
            self.window.iter().map(|f| f.speed_kmh).collect(),
            self.window.iter().map(|f| f.g_lateral).collect(),
            self.window.iter().map(|f| f.g_longitudinal).collect(),
            self.window.iter().map(|f| f.g_vertical).collect(),
            self.window.iter().map(|f| f.heading_deg).collect(),
            self.window.iter().map(|f| f.altitude_m).collect(),
        ];

        // Compute 4 statistics per channel: mean, std, min, max
        for channel in &channels {
            let sum: f32 = channel.iter().sum();
            let mean = sum / n;

            let variance: f32 = channel.iter().map(|v| (v - mean) * (v - mean)).sum::<f32>() / n;
            let std = variance.sqrt();

            let min = channel
                .iter()
                .copied()
                .min_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal))
                .unwrap_or(0.0);
            let max = channel
                .iter()
                .copied()
                .max_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal))
                .unwrap_or(0.0);

            features.push(mean);
            features.push(std);
            features.push(min);
            features.push(max);
        }

        // Derived features

        // 1. Speed range (max - min) — how much speed changed in the window
        let speed_range = features[2] - features[3]; // max - min (indices: speed_min=2, speed_max=3)
                                                     // Actually: features[0]=speed_mean, [1]=speed_std, [2]=speed_min, [3]=speed_max
        features.push(features[3] - features[2]); // speed_max - speed_min

        // 2. Combined G magnitude mean
        let g_total_mean: f32 = self
            .window
            .iter()
            .map(|f| (f.g_lateral * f.g_lateral + f.g_longitudinal * f.g_longitudinal).sqrt())
            .sum::<f32>()
            / n;
        features.push(g_total_mean);

        // Ensure consistent size (drop the incorrect speed_range we didn't use)
        let _ = speed_range;

        debug_assert_eq!(features.len(), FEATURE_COUNT);

        Some(features)
    }

    /// Reset the window.
    pub fn reset(&mut self) {
        self.window.clear();
    }
}

impl Default for FeatureExtractor {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_input(speed: f32, g_lat: f32, g_long: f32) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms: 0,
            latitude: 0.0,
            longitude: 0.0,
            speed_kmh: speed,
            heading_deg: 90.0,
            altitude_m: 100.0,
            g_lateral: g_lat,
            g_longitudinal: g_long,
            g_vertical: 1.0,
            satellites: 12,
            hdop: 1.0,
        }
    }

    #[test]
    fn test_not_ready_until_window_full() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 5 });
        for i in 0..4 {
            fe.push(make_input(100.0 + i as f32, 0.0, 0.0));
            assert!(!fe.is_ready());
        }
        fe.push(make_input(104.0, 0.0, 0.0));
        assert!(fe.is_ready());
    }

    #[test]
    fn test_extract_feature_count() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 5 });
        for i in 0..5 {
            fe.push(make_input(
                100.0 + i as f32,
                0.1 * i as f32,
                -0.05 * i as f32,
            ));
        }
        let features = fe.extract().unwrap();
        assert_eq!(features.len(), FEATURE_COUNT);
    }

    #[test]
    fn test_constant_speed_zero_std() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 5 });
        for _ in 0..5 {
            fe.push(make_input(100.0, 0.0, 0.0));
        }
        let features = fe.extract().unwrap();
        // Speed mean
        assert!((features[0] - 100.0).abs() < 0.01);
        // Speed std
        assert!(features[1] < 0.01);
        // Speed min == max
        assert!((features[2] - features[3]).abs() < 0.01);
    }

    #[test]
    fn test_sliding_window_eviction() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 3 });
        fe.push(make_input(50.0, 0.0, 0.0));
        fe.push(make_input(60.0, 0.0, 0.0));
        fe.push(make_input(70.0, 0.0, 0.0));

        // Push one more — evicts 50.0
        fe.push(make_input(80.0, 0.0, 0.0));

        let features = fe.extract().unwrap();
        // Mean should be (60+70+80)/3 = 70
        assert!((features[0] - 70.0).abs() < 0.01);
    }

    #[test]
    fn test_g_total_derived_feature() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 3 });
        // g_lat=0.3, g_long=-0.4 → g_total = 0.5
        for _ in 0..3 {
            fe.push(make_input(100.0, 0.3, -0.4));
        }
        let features = fe.extract().unwrap();
        // Last feature is g_total_mean
        let g_total = features[FEATURE_COUNT - 1];
        assert!((g_total - 0.5).abs() < 0.01);
    }

    #[test]
    fn test_reset_clears_window() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 3 });
        for _ in 0..3 {
            fe.push(make_input(100.0, 0.0, 0.0));
        }
        assert!(fe.is_ready());
        fe.reset();
        assert!(!fe.is_ready());
        assert!(fe.extract().is_none());
    }
}
