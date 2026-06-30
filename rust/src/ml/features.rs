//! Feature extraction for ML models.
//!
//! Computes fixed-size feature vectors from a sliding window of telemetry
//! frames. Features include statistical aggregates (mean, std, min, max)
//! of speed, G-forces, and derived quantities like jerk and grip utilization.
//!
//! Window size: configurable, typically 25 frames (1 second at 25 Hz).
//! Output: flat f32 vector suitable for TFLite inference.
//!
//! **Heading**: Uses circular statistics (atan2 of mean sin/cos) to correctly
//! handle the 360° → 0° wrap-around.

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
    ///
    /// Feature layout:
    ///   [0..4]   speed:    mean, std, min, max
    ///   [4..8]   g_lat:    mean, std, min, max
    ///   [8..12]  g_long:   mean, std, min, max
    ///   [12..16] g_vert:   mean, std, min, max
    ///   [16..20] altitude: mean, std, min, max
    ///   [20..24] heading:  circular_mean, circular_std, min_dev, max_dev
    ///   [24]     speed_range (max - min)
    ///   [25]     g_total_mean (combined lateral + longitudinal magnitude)
    pub fn extract(&self) -> Option<Vec<f32>> {
        if !self.is_ready() {
            return None;
        }

        let n = self.window.len() as f32;
        let mut features = Vec::with_capacity(FEATURE_COUNT);

        // ── Linear channels (single-pass) ────────────────────────────────
        // Channels: speed, g_lat, g_long, g_vert, altitude (5 linear channels)
        let mut sums = [0.0_f32; 5];
        let mut mins = [f32::MAX; 5];
        let mut maxs = [f32::MIN; 5];
        // For heading (circular): accumulate sin/cos
        let mut sin_sum = 0.0_f64;
        let mut cos_sum = 0.0_f64;
        // For g_total derived feature
        let mut g_total_sum = 0.0_f32;

        for frame in &self.window {
            let vals = [
                frame.speed_kmh,
                frame.g_lateral,
                frame.g_longitudinal,
                frame.g_vertical,
                frame.altitude_m,
            ];
            for (i, &v) in vals.iter().enumerate() {
                sums[i] += v;
                mins[i] = mins[i].min(v);
                maxs[i] = maxs[i].max(v);
            }

            // Circular heading accumulation
            let rad = (frame.heading_deg as f64).to_radians();
            sin_sum += rad.sin();
            cos_sum += rad.cos();

            // Combined G magnitude
            g_total_sum += (frame.g_lateral * frame.g_lateral
                + frame.g_longitudinal * frame.g_longitudinal)
                .sqrt();
        }

        // Compute mean and std for each linear channel (second pass for variance)
        let means: [f32; 5] = std::array::from_fn(|i| sums[i] / n);

        for (i, &mean) in means.iter().enumerate() {
            let accessor: fn(&TelemetryInput) -> f32 = match i {
                0 => |f| f.speed_kmh,
                1 => |f| f.g_lateral,
                2 => |f| f.g_longitudinal,
                3 => |f| f.g_vertical,
                4 => |f| f.altitude_m,
                _ => unreachable!(),
            };
            let variance: f32 = self
                .window
                .iter()
                .map(|f| {
                    let v = accessor(f);
                    (v - mean) * (v - mean)
                })
                .sum::<f32>()
                / n;
            let std = variance.sqrt();

            features.push(mean);
            features.push(std);
            features.push(mins[i]);
            features.push(maxs[i]);
        }

        // ── Heading (circular statistics) ────────────────────────────────
        let n_f64 = self.window.len() as f64;
        let heading_mean_rad = (sin_sum / n_f64).atan2(cos_sum / n_f64);
        let heading_mean_deg = heading_mean_rad.to_degrees();
        // Normalize to [0, 360)
        let heading_mean_deg = ((heading_mean_deg % 360.0) + 360.0) % 360.0;

        // Circular standard deviation: sqrt(-2 * ln(R)), where R = |mean resultant|
        let r_bar = ((sin_sum / n_f64).powi(2) + (cos_sum / n_f64).powi(2)).sqrt();
        let heading_std_deg = if r_bar > 0.0 && r_bar <= 1.0 {
            ((-2.0 * r_bar.ln()).sqrt()).to_degrees()
        } else if r_bar > 1.0 {
            // Numerical safety: R slightly > 1 due to floating point
            0.0
        } else {
            // R = 0 means uniform distribution
            180.0
        };

        // Min/max angular deviation from circular mean
        let mut min_dev = f32::MAX;
        let mut max_dev = f32::MIN;
        for frame in &self.window {
            let diff = angular_diff(frame.heading_deg as f64, heading_mean_deg);
            let diff_f32 = diff as f32;
            min_dev = min_dev.min(diff_f32);
            max_dev = max_dev.max(diff_f32);
        }

        features.push(heading_mean_deg as f32);
        features.push(heading_std_deg as f32);
        features.push(min_dev);
        features.push(max_dev);

        // ── Derived features ─────────────────────────────────────────────

        // Speed range (max - min)
        features.push(maxs[0] - mins[0]);

        // Combined G magnitude mean
        features.push(g_total_sum / n);

        debug_assert_eq!(features.len(), FEATURE_COUNT);

        Some(features)
    }

    /// Reset the window.
    pub fn reset(&mut self) {
        self.window.clear();
    }
}

/// Signed angular difference in degrees, range [-180, 180].
fn angular_diff(a_deg: f64, b_deg: f64) -> f64 {
    let mut d = a_deg - b_deg;
    while d > 180.0 {
        d -= 360.0;
    }
    while d < -180.0 {
        d += 360.0;
    }
    d
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
        make_input_full(speed, g_lat, g_long, 90.0, 100.0)
    }

    fn make_input_full(
        speed: f32,
        g_lat: f32,
        g_long: f32,
        heading: f32,
        altitude: f32,
    ) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms: 0,
            latitude: 0.0,
            longitude: 0.0,
            speed_kmh: speed,
            heading_deg: heading,
            altitude_m: altitude,
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

    // ── Heading wrap-around tests ────────────────────────────────────────

    #[test]
    fn test_heading_no_wrap_consistent_direction() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 3 });
        for _ in 0..3 {
            fe.push(make_input_full(100.0, 0.0, 0.0, 90.0, 100.0));
        }
        let features = fe.extract().unwrap();
        // Heading mean (index 20) should be 90
        assert!(
            (features[20] - 90.0).abs() < 1.0,
            "heading mean should be ~90, got {}",
            features[20]
        );
        // Heading std (index 21) should be ~0
        assert!(
            features[21] < 1.0,
            "heading std should be ~0, got {}",
            features[21]
        );
    }

    #[test]
    fn test_heading_wrap_around_north() {
        // Critical test: heading crosses 360°/0° boundary
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 5 });
        fe.push(make_input_full(100.0, 0.0, 0.0, 358.0, 100.0));
        fe.push(make_input_full(100.0, 0.0, 0.0, 359.0, 100.0));
        fe.push(make_input_full(100.0, 0.0, 0.0, 0.0, 100.0));
        fe.push(make_input_full(100.0, 0.0, 0.0, 1.0, 100.0));
        fe.push(make_input_full(100.0, 0.0, 0.0, 2.0, 100.0));

        let features = fe.extract().unwrap();
        let heading_mean = features[20];
        let heading_std = features[21];

        // Mean should be ~0° (north), NOT ~144° (naive arithmetic mean)
        // Angular distance from north: min(heading, 360-heading)
        let dist_from_north = heading_mean.min(360.0 - heading_mean);
        assert!(
            dist_from_north < 10.0,
            "heading mean should be near 0°/360°, got {heading_mean}°"
        );
        // Std should be small (~2°), not ~170°
        assert!(
            heading_std < 10.0,
            "heading std should be small, got {heading_std}°"
        );
    }

    #[test]
    fn test_heading_wrap_south() {
        // Heading around 180° — no wrap issue, but verify correctness
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 3 });
        fe.push(make_input_full(100.0, 0.0, 0.0, 179.0, 100.0));
        fe.push(make_input_full(100.0, 0.0, 0.0, 180.0, 100.0));
        fe.push(make_input_full(100.0, 0.0, 0.0, 181.0, 100.0));

        let features = fe.extract().unwrap();
        let heading_mean = features[20];
        assert!(
            (heading_mean - 180.0).abs() < 2.0,
            "heading mean should be ~180°, got {heading_mean}°"
        );
    }

    #[test]
    fn test_speed_range_derived_feature() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 3 });
        fe.push(make_input(80.0, 0.0, 0.0));
        fe.push(make_input(100.0, 0.0, 0.0));
        fe.push(make_input(120.0, 0.0, 0.0));

        let features = fe.extract().unwrap();
        // speed_range = features[24] = max - min = 120 - 80 = 40
        assert!(
            (features[24] - 40.0).abs() < 0.01,
            "speed range should be 40, got {}",
            features[24]
        );
    }

    #[test]
    fn test_no_nan_with_zero_g() {
        let mut fe = FeatureExtractor::with_config(FeatureConfig { window_size: 3 });
        for _ in 0..3 {
            fe.push(make_input(0.0, 0.0, 0.0));
        }
        let features = fe.extract().unwrap();
        for (i, &f) in features.iter().enumerate() {
            assert!(!f.is_nan(), "Feature {i} is NaN");
            assert!(!f.is_infinite(), "Feature {i} is infinite");
        }
    }
}
