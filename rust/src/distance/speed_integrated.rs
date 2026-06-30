//! Speed-integrated distance — the primary, always-on distance channel.
//!
//! Computes distance traveled by integrating GPS speed over time:
//! d += v × dt (trapezoidal integration for better accuracy)
//!
//! Works on ANY track with zero configuration. Resets on finish line crossing.
//! Typical drift: ±1-3% over a lap, which is acceptable for relative
//! comparison against a reference lap using the same integration method.

use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};

/// Speed-integrated distance analyzer.
pub struct SpeedIntegratedDistance {
    enabled: bool,
    distance_m: f64,
    prev_speed_ms: Option<f64>,
}

impl SpeedIntegratedDistance {
    pub fn new() -> Self {
        Self {
            enabled: true,
            distance_m: 0.0,
            prev_speed_ms: None,
        }
    }

    /// Get current accumulated distance in meters.
    pub fn current_distance(&self) -> f64 {
        self.distance_m
    }

    /// Reset distance to zero (e.g., on finish line crossing).
    pub fn reset_distance(&mut self) {
        self.distance_m = 0.0;
        self.prev_speed_ms = None;
    }
}

impl Default for SpeedIntegratedDistance {
    fn default() -> Self {
        Self::new()
    }
}

impl TelemetryAnalyzer for SpeedIntegratedDistance {
    fn id(&self) -> &str {
        "speed_integrated_distance"
    }

    fn display_name(&self) -> &str {
        "Speed-Integrated Distance"
    }

    fn is_enabled(&self) -> bool {
        self.enabled
    }

    fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    fn requirements(&self) -> &[DataRequirement] {
        &[DataRequirement::Gps]
    }

    fn analyze(&mut self, ctx: &AnalysisContext) -> Vec<AnalysisResult> {
        let speed_ms = ctx.current.speed_kmh as f64 / 3.6;

        // Trapezoidal integration: d += (v_prev + v_curr) / 2 × dt
        if let Some(prev_speed) = self.prev_speed_ms {
            if ctx.dt > 0.0 && ctx.dt < 1.0 {
                // dt sanity check: ignore gaps > 1 second
                let avg_speed = (prev_speed + speed_ms) / 2.0;
                self.distance_m += avg_speed * ctx.dt;
            }
        }

        self.prev_speed_ms = Some(speed_ms);

        vec![AnalysisResult::Distance(self.distance_m)]
    }

    fn reset(&mut self) {
        self.reset_distance();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::TelemetryInput;

    fn make_input(speed_kmh: f32) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms: 0,
            latitude: 0.0,
            longitude: 0.0,
            speed_kmh,
            heading_deg: 0.0,
            altitude_m: 0.0,
            g_lateral: 0.0,
            g_longitudinal: 0.0,
            g_vertical: 1.0,
            satellites: 12,
            hdop: 1.0,
        }
    }

    #[test]
    fn test_constant_speed_distance() {
        let mut sid = SpeedIntegratedDistance::new();

        // Drive at 100 km/h (27.78 m/s) for 1 second (25 frames at 40ms)
        let input = make_input(100.0);
        let dt = 0.04; // 25 Hz

        let mut ctx = AnalysisContext {
            current: &input,
            previous: None,
            dt,
            track_distance_m: 0.0,
            reference_frame: None,
            reference_lap_distance_m: None,
        };

        // First frame initializes, no distance added
        sid.analyze(&ctx);

        // 24 more frames at same speed
        for _ in 0..24 {
            ctx.previous = Some(&input);
            let results = sid.analyze(&ctx);

            if let Some(AnalysisResult::Distance(_)) = results.first() {
                // ok
            } else {
                panic!("Expected Distance result");
            }
        }

        // After 25 frames at 40ms = 1.0 second at 27.78 m/s ≈ 27.78m
        // But first frame doesn't integrate, so 24 × 0.04 × 27.78 ≈ 26.67m
        let d = sid.current_distance();
        assert!((d - 26.67).abs() < 0.5, "Expected ~26.67m, got {d}m");
    }

    #[test]
    fn test_zero_speed() {
        let mut sid = SpeedIntegratedDistance::new();
        let input = make_input(0.0);
        let ctx = AnalysisContext {
            current: &input,
            previous: Some(&input),
            dt: 0.04,
            track_distance_m: 0.0,
            reference_frame: None,
            reference_lap_distance_m: None,
        };

        sid.analyze(&ctx);
        sid.analyze(&ctx);
        sid.analyze(&ctx);

        assert!(sid.current_distance().abs() < 1e-10);
    }

    #[test]
    fn test_reset() {
        let mut sid = SpeedIntegratedDistance::new();
        let input = make_input(100.0);
        let ctx = AnalysisContext {
            current: &input,
            previous: Some(&input),
            dt: 0.04,
            track_distance_m: 0.0,
            reference_frame: None,
            reference_lap_distance_m: None,
        };

        sid.analyze(&ctx);
        sid.analyze(&ctx);
        assert!(sid.current_distance() > 0.0);

        sid.reset();
        assert!(sid.current_distance().abs() < 1e-10);
    }
}
