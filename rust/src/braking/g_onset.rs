//! G-force based braking onset detection.
//!
//! Detects the start and end of braking by monitoring longitudinal G-force.
//! Uses a threshold with hysteresis to avoid chatter.
//!
//! Braking onset: G_long < -threshold for ≥ min_frames consecutive frames
//! Braking release: G_long > -(threshold × hysteresis) for ≥ min_frames frames

use crate::math::filters::ExponentialFilter;
use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};
use crate::types::BrakingState;

/// Configuration for braking onset detection.
#[derive(Debug, Clone, Copy)]
pub struct BrakingOnsetConfig {
    /// G-force threshold to trigger braking detection (positive value, e.g., 0.3g).
    pub threshold_g: f32,
    /// Hysteresis factor for release (0.0-1.0). Release at threshold × hysteresis.
    pub hysteresis: f32,
    /// Minimum consecutive frames to confirm onset/release.
    pub min_frames: u32,
    /// Smoothing factor for the G-force filter (0.0-1.0).
    pub smoothing_alpha: f64,
}

impl Default for BrakingOnsetConfig {
    fn default() -> Self {
        Self {
            threshold_g: 0.3,
            hysteresis: 0.5,
            min_frames: 3,
            smoothing_alpha: 0.4,
        }
    }
}

/// G-force based braking onset detector.
pub struct BrakingOnsetDetector {
    enabled: bool,
    config: BrakingOnsetConfig,
    filter: ExponentialFilter,

    is_braking: bool,
    consecutive_frames: u32,
    distance_at_onset: f64,
    current_braking_g: f32,
}

impl BrakingOnsetDetector {
    pub fn new() -> Self {
        Self::with_config(BrakingOnsetConfig::default())
    }

    pub fn with_config(config: BrakingOnsetConfig) -> Self {
        Self {
            enabled: true,
            config,
            filter: ExponentialFilter::new(config.smoothing_alpha),
            is_braking: false,
            consecutive_frames: 0,
            distance_at_onset: 0.0,
            current_braking_g: 0.0,
        }
    }
}

impl Default for BrakingOnsetDetector {
    fn default() -> Self {
        Self::new()
    }
}

impl TelemetryAnalyzer for BrakingOnsetDetector {
    fn id(&self) -> &str {
        "braking_g_onset"
    }

    fn display_name(&self) -> &str {
        "Braking Onset (G-Force)"
    }

    fn is_enabled(&self) -> bool {
        self.enabled
    }

    fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    fn requirements(&self) -> &[DataRequirement] {
        &[DataRequirement::Imu]
    }

    fn analyze(&mut self, ctx: &AnalysisContext) -> Vec<AnalysisResult> {
        let filtered_g = self.filter.update(ctx.current.g_longitudinal as f64) as f32;

        let threshold = self.config.threshold_g;
        let release_threshold = threshold * self.config.hysteresis;

        if !self.is_braking {
            // Check for braking onset
            if filtered_g < -threshold {
                self.consecutive_frames += 1;
                if self.consecutive_frames >= self.config.min_frames {
                    self.is_braking = true;
                    self.distance_at_onset = ctx.track_distance_m;
                    self.current_braking_g = filtered_g;
                    self.consecutive_frames = 0;
                }
            } else {
                self.consecutive_frames = 0;
            }
        } else {
            // Check for braking release
            self.current_braking_g = filtered_g.min(self.current_braking_g);

            if filtered_g > -release_threshold {
                self.consecutive_frames += 1;
                if self.consecutive_frames >= self.config.min_frames {
                    self.is_braking = false;
                    self.consecutive_frames = 0;
                }
            } else {
                self.consecutive_frames = 0;
            }
        }

        let distance_since_onset = if self.is_braking {
            (ctx.track_distance_m - self.distance_at_onset) as f32
        } else {
            0.0
        };

        vec![AnalysisResult::BrakingUpdate(BrakingState {
            is_braking: self.is_braking,
            braking_g: filtered_g,
            distance_since_onset,
            reference_onset_delta_m: None, // Set later by CueEngine
        })]
    }

    fn reset(&mut self) {
        self.is_braking = false;
        self.consecutive_frames = 0;
        self.distance_at_onset = 0.0;
        self.current_braking_g = 0.0;
        self.filter.reset();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::TelemetryInput;

    fn make_input(g_long: f32) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms: 0,
            latitude: 0.0,
            longitude: 0.0,
            speed_kmh: 100.0,
            heading_deg: 0.0,
            altitude_m: 0.0,
            g_lateral: 0.0,
            g_longitudinal: g_long,
            g_vertical: 1.0,
            satellites: 12,
            hdop: 1.0,
        }
    }

    fn make_ctx<'a>(input: &'a TelemetryInput, distance: f64) -> AnalysisContext<'a> {
        AnalysisContext {
            current: input,
            previous: None,
            dt: 0.04,
            track_distance_m: distance,
            reference_frame: None,
            reference_lap_distance_m: None,
        }
    }

    #[test]
    fn test_no_braking_at_low_g() {
        let mut detector = BrakingOnsetDetector::new();
        let input = make_input(-0.1); // Below threshold
        let ctx = make_ctx(&input, 100.0);

        for _ in 0..10 {
            let results = detector.analyze(&ctx);
            if let AnalysisResult::BrakingUpdate(state) = &results[0] {
                assert!(!state.is_braking);
            }
        }
    }

    #[test]
    fn test_braking_detected_after_min_frames() {
        let mut detector = BrakingOnsetDetector::with_config(BrakingOnsetConfig {
            threshold_g: 0.3,
            min_frames: 3,
            smoothing_alpha: 1.0, // No filtering for test
            ..Default::default()
        });

        let input = make_input(-0.5); // Above threshold
        let ctx = make_ctx(&input, 100.0);

        // First two frames: not yet confirmed
        for _ in 0..2 {
            let results = detector.analyze(&ctx);
            if let AnalysisResult::BrakingUpdate(state) = &results[0] {
                assert!(!state.is_braking, "Should not be braking yet");
            }
        }

        // Third frame: confirmed
        let results = detector.analyze(&ctx);
        if let AnalysisResult::BrakingUpdate(state) = &results[0] {
            assert!(state.is_braking, "Should be braking after min_frames");
        }
    }
}
