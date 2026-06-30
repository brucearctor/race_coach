//! Friction circle (G-G diagram) analysis.
//!
//! Tracks the magnitude of combined lateral and longitudinal G-forces
//! relative to the historical maximum. A utilization of 1.0 means the
//! driver is using all available grip.
//!
//! Also detects coasting (low total G) and trail braking (simultaneous
//! braking + cornering).

use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};
use crate::types::FrictionCircleState;

/// Configuration for friction circle analysis.
#[derive(Debug, Clone, Copy)]
pub struct FrictionCircleConfig {
    /// G_max decays toward current max to adapt to changing conditions.
    /// Higher value = slower adaptation. Typical: 0.999 at 25 Hz.
    pub g_max_decay: f32,
    /// Below this total G for coasting_duration_s, flag as coasting.
    pub coasting_threshold_g: f32,
    /// Seconds of low-G needed to trigger coasting flag.
    pub coasting_duration_s: f32,
    /// Trail braking detection: both lateral and longitudinal must exceed this.
    pub trail_braking_min_g: f32,
}

impl Default for FrictionCircleConfig {
    fn default() -> Self {
        Self {
            g_max_decay: 0.999,
            coasting_threshold_g: 0.3,
            coasting_duration_s: 1.5,
            trail_braking_min_g: 0.2,
        }
    }
}

/// Friction circle analyzer.
pub struct FrictionCircle {
    enabled: bool,
    config: FrictionCircleConfig,
    g_max: f32,
    coasting_frames: u32,
    frames_for_coasting: u32,
}

impl FrictionCircle {
    pub fn new() -> Self {
        Self::with_config(FrictionCircleConfig::default())
    }

    pub fn with_config(config: FrictionCircleConfig) -> Self {
        let frames_for_coasting = (config.coasting_duration_s * 25.0) as u32;
        Self {
            enabled: true,
            config,
            g_max: 0.5, // Reasonable starting value
            coasting_frames: 0,
            frames_for_coasting,
        }
    }
}

impl Default for FrictionCircle {
    fn default() -> Self {
        Self::new()
    }
}

impl TelemetryAnalyzer for FrictionCircle {
    fn id(&self) -> &str {
        "friction_circle"
    }

    fn display_name(&self) -> &str {
        "Friction Circle"
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
        let g_lat = ctx.current.g_lateral;
        let g_long = ctx.current.g_longitudinal;
        let g_total = (g_lat * g_lat + g_long * g_long).sqrt();

        // Update maximum with decay
        self.g_max *= self.config.g_max_decay;
        if g_total > self.g_max {
            self.g_max = g_total;
        }

        let utilization = if self.g_max > 0.01 {
            (g_total / self.g_max).min(1.0)
        } else {
            0.0
        };

        // Coasting detection
        if g_total < self.config.coasting_threshold_g {
            self.coasting_frames += 1;
        } else {
            self.coasting_frames = 0;
        }
        let is_coasting = self.coasting_frames >= self.frames_for_coasting;

        // Trail braking detection
        let is_trail_braking = g_lat.abs() > self.config.trail_braking_min_g
            && g_long < -self.config.trail_braking_min_g;

        vec![AnalysisResult::FrictionUpdate(FrictionCircleState {
            g_total,
            g_max: self.g_max,
            utilization,
            is_coasting,
            is_trail_braking,
        })]
    }

    fn reset(&mut self) {
        self.g_max = 0.5;
        self.coasting_frames = 0;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::TelemetryInput;

    fn make_input(g_lat: f32, g_long: f32) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms: 0,
            latitude: 0.0,
            longitude: 0.0,
            speed_kmh: 100.0,
            heading_deg: 0.0,
            altitude_m: 0.0,
            g_lateral: g_lat,
            g_longitudinal: g_long,
            g_vertical: 1.0,
            satellites: 12,
            hdop: 1.0,
        }
    }

    fn make_ctx(input: &TelemetryInput) -> AnalysisContext<'_> {
        AnalysisContext {
            current: input,
            previous: None,
            dt: 0.04,
            track_distance_m: 100.0,
            reference_frame: None,
            reference_lap_distance_m: None,
        }
    }

    #[test]
    fn test_utilization_under_max() {
        let mut fc = FrictionCircle::new();
        // First, establish g_max with a high-G frame
        let high_g = make_input(1.0, -0.5);
        fc.analyze(&make_ctx(&high_g));

        // Now a lower-G frame should show partial utilization
        let low_g = make_input(0.5, -0.2);
        let results = fc.analyze(&make_ctx(&low_g));
        if let AnalysisResult::FrictionUpdate(state) = &results[0] {
            assert!(state.utilization < 1.0);
            assert!(state.utilization > 0.0);
        }
    }

    #[test]
    fn test_trail_braking_detected() {
        let mut fc = FrictionCircle::new();
        // Simultaneous cornering and braking
        let input = make_input(0.5, -0.4);
        let results = fc.analyze(&make_ctx(&input));
        if let AnalysisResult::FrictionUpdate(state) = &results[0] {
            assert!(state.is_trail_braking);
        }
    }

    #[test]
    fn test_not_trail_braking_when_only_cornering() {
        let mut fc = FrictionCircle::new();
        let input = make_input(0.8, 0.0); // Only lateral
        let results = fc.analyze(&make_ctx(&input));
        if let AnalysisResult::FrictionUpdate(state) = &results[0] {
            assert!(!state.is_trail_braking);
        }
    }
}
