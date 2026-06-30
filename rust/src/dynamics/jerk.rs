//! Jerk analysis (rate of change of G-force).
//!
//! Jerk measures how abruptly the driver applies/releases controls.
//! High jerk = sudden inputs (can upset the car's balance).
//! Low jerk = smooth inputs (better grip transfer).
//!
//! This analyzer tracks longitudinal and lateral jerk, emitting coaching
//! cues when jerk exceeds thresholds.

use crate::math::filters::ExponentialFilter;
use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};
use crate::types::{CoachingCue, CuePriority, CueType};

/// Configuration for jerk analysis.
#[derive(Debug, Clone, Copy)]
pub struct JerkConfig {
    /// Jerk threshold (g/s) for longitudinal axis (braking/accel).
    pub longitudinal_threshold: f32,
    /// Jerk threshold (g/s) for lateral axis (steering).
    pub lateral_threshold: f32,
    /// Smoothing for jerk signal.
    pub smoothing_alpha: f64,
    /// Cooldown frames between cues.
    pub cooldown_frames: u32,
    /// Minimum speed (km/h) to analyze — low speed jerk is normal.
    pub min_speed_kmh: f32,
}

impl Default for JerkConfig {
    fn default() -> Self {
        Self {
            longitudinal_threshold: 8.0, // g/s — quite aggressive
            lateral_threshold: 6.0,
            smoothing_alpha: 0.5,
            cooldown_frames: 50,
            min_speed_kmh: 40.0,
        }
    }
}

/// Jerk analyzer — rate of change of G-force.
pub struct JerkAnalyzer {
    enabled: bool,
    config: JerkConfig,
    long_filter: ExponentialFilter,
    lat_filter: ExponentialFilter,
    prev_g_long: Option<f32>,
    prev_g_lat: Option<f32>,
    cooldown_remaining: u32,
}

impl JerkAnalyzer {
    pub fn new() -> Self {
        Self::with_config(JerkConfig::default())
    }

    pub fn with_config(config: JerkConfig) -> Self {
        Self {
            enabled: false, // Disabled by default
            config,
            long_filter: ExponentialFilter::new(config.smoothing_alpha),
            lat_filter: ExponentialFilter::new(config.smoothing_alpha),
            prev_g_long: None,
            prev_g_lat: None,
            cooldown_remaining: 0,
        }
    }
}

impl Default for JerkAnalyzer {
    fn default() -> Self {
        Self::new()
    }
}

impl TelemetryAnalyzer for JerkAnalyzer {
    fn id(&self) -> &str {
        "jerk_analysis"
    }

    fn display_name(&self) -> &str {
        "Jerk Analysis"
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
        let mut results = Vec::new();

        if self.cooldown_remaining > 0 {
            self.cooldown_remaining -= 1;
        }

        // Skip at low speed
        if ctx.current.speed_kmh < self.config.min_speed_kmh {
            self.prev_g_long = Some(ctx.current.g_longitudinal);
            self.prev_g_lat = Some(ctx.current.g_lateral);
            return results;
        }

        if ctx.dt <= 0.0 {
            self.prev_g_long = Some(ctx.current.g_longitudinal);
            self.prev_g_lat = Some(ctx.current.g_lateral);
            return results;
        }

        if let (Some(prev_long), Some(prev_lat)) = (self.prev_g_long, self.prev_g_lat) {
            // Compute raw jerk (g/s)
            let jerk_long = (ctx.current.g_longitudinal - prev_long) / ctx.dt as f32;
            let jerk_lat = (ctx.current.g_lateral - prev_lat) / ctx.dt as f32;

            // Smooth
            let jerk_long_smooth = self.long_filter.update(jerk_long as f64) as f32;
            let jerk_lat_smooth = self.lat_filter.update(jerk_lat as f64) as f32;

            if self.cooldown_remaining == 0 {
                // Check longitudinal jerk (braking/throttle)
                if jerk_long_smooth.abs() > self.config.longitudinal_threshold {
                    let action = if jerk_long_smooth < 0.0 {
                        "brake"
                    } else {
                        "throttle"
                    };
                    results.push(AnalysisResult::Cue(CoachingCue {
                        cue_type: CueType::Braking,
                        message: format!(
                            "Smooth the {action} application — {:.0} g/s jerk",
                            jerk_long_smooth.abs()
                        ),
                        priority: CuePriority::Medium,
                        corner_number: None,
                        delta_seconds: None,
                        distance_delta_m: None,
                    }));
                    self.cooldown_remaining = self.config.cooldown_frames;
                }
                // Check lateral jerk (steering)
                else if jerk_lat_smooth.abs() > self.config.lateral_threshold {
                    results.push(AnalysisResult::Cue(CoachingCue {
                        cue_type: CueType::Line,
                        message: format!(
                            "Smoother steering input — {:.0} g/s lateral jerk",
                            jerk_lat_smooth.abs()
                        ),
                        priority: CuePriority::Low,
                        corner_number: None,
                        delta_seconds: None,
                        distance_delta_m: None,
                    }));
                    self.cooldown_remaining = self.config.cooldown_frames;
                }
            }
        }

        self.prev_g_long = Some(ctx.current.g_longitudinal);
        self.prev_g_lat = Some(ctx.current.g_lateral);

        results
    }

    fn reset(&mut self) {
        self.prev_g_long = None;
        self.prev_g_lat = None;
        self.cooldown_remaining = 0;
        self.long_filter.reset();
        self.lat_filter.reset();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::TelemetryInput;

    fn make_input(g_lat: f32, g_long: f32, speed: f32) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms: 0,
            latitude: 0.0,
            longitude: 0.0,
            speed_kmh: speed,
            heading_deg: 0.0,
            altitude_m: 0.0,
            g_lateral: g_lat,
            g_longitudinal: g_long,
            g_vertical: 1.0,
            satellites: 12,
            hdop: 1.0,
        }
    }

    fn make_ctx<'a>(current: &'a TelemetryInput, dt: f64) -> AnalysisContext<'a> {
        AnalysisContext {
            current,
            previous: None,
            dt,
            track_distance_m: 100.0,
            reference_frame: None,
            reference_lap_distance_m: None,
        }
    }

    #[test]
    fn test_no_jerk_on_first_frame() {
        let mut analyzer = JerkAnalyzer::new();
        analyzer.set_enabled(true);
        let input = make_input(0.0, -0.5, 100.0);
        let results = analyzer.analyze(&make_ctx(&input, 0.04));
        assert!(results.is_empty());
    }

    #[test]
    fn test_high_braking_jerk_triggers_cue() {
        let mut analyzer = JerkAnalyzer::with_config(JerkConfig {
            longitudinal_threshold: 5.0,
            smoothing_alpha: 1.0, // No smoothing
            cooldown_frames: 0,
            min_speed_kmh: 0.0,
            ..Default::default()
        });
        analyzer.set_enabled(true);

        // Frame 1: no braking
        let f1 = make_input(0.0, 0.0, 100.0);
        analyzer.analyze(&make_ctx(&f1, 0.04));

        // Frame 2: sudden hard braking = high jerk
        let f2 = make_input(0.0, -1.0, 100.0);
        let results = analyzer.analyze(&make_ctx(&f2, 0.04));

        // Jerk = (-1.0 - 0.0) / 0.04 = -25 g/s, abs > threshold 5
        assert_eq!(results.len(), 1);
        match &results[0] {
            AnalysisResult::Cue(cue) => {
                assert!(cue.message.contains("brake"));
            }
            _ => panic!("Expected Cue"),
        }
    }

    #[test]
    fn test_smooth_braking_no_cue() {
        let mut analyzer = JerkAnalyzer::with_config(JerkConfig {
            longitudinal_threshold: 5.0,
            smoothing_alpha: 1.0,
            cooldown_frames: 0,
            min_speed_kmh: 0.0,
            ..Default::default()
        });
        analyzer.set_enabled(true);

        // Frame 1
        let f1 = make_input(0.0, -0.3, 100.0);
        analyzer.analyze(&make_ctx(&f1, 0.04));

        // Frame 2: gentle increase
        let f2 = make_input(0.0, -0.35, 100.0);
        let results = analyzer.analyze(&make_ctx(&f2, 0.04));

        // Jerk = (-0.35 - -0.3) / 0.04 = -1.25 g/s, below threshold
        assert!(results.is_empty());
    }

    #[test]
    fn test_low_speed_ignored() {
        let mut analyzer = JerkAnalyzer::with_config(JerkConfig {
            min_speed_kmh: 40.0,
            smoothing_alpha: 1.0,
            cooldown_frames: 0,
            longitudinal_threshold: 1.0,
            ..Default::default()
        });
        analyzer.set_enabled(true);

        let f1 = make_input(0.0, 0.0, 20.0);
        analyzer.analyze(&make_ctx(&f1, 0.04));

        let f2 = make_input(0.0, -1.0, 20.0);
        let results = analyzer.analyze(&make_ctx(&f2, 0.04));

        assert!(results.is_empty(), "Low speed jerk should be ignored");
    }

    #[test]
    fn test_lateral_jerk_triggers_cue() {
        let mut analyzer = JerkAnalyzer::with_config(JerkConfig {
            lateral_threshold: 5.0,
            longitudinal_threshold: 100.0, // Won't trigger
            smoothing_alpha: 1.0,
            cooldown_frames: 0,
            min_speed_kmh: 0.0,
        });
        analyzer.set_enabled(true);

        let f1 = make_input(0.0, 0.0, 100.0);
        analyzer.analyze(&make_ctx(&f1, 0.04));

        // Sudden steering input
        let f2 = make_input(0.8, 0.0, 100.0);
        let results = analyzer.analyze(&make_ctx(&f2, 0.04));

        // Jerk = 0.8 / 0.04 = 20 g/s
        assert_eq!(results.len(), 1);
        match &results[0] {
            AnalysisResult::Cue(cue) => {
                assert!(cue.message.contains("steering"));
            }
            _ => panic!("Expected Cue"),
        }
    }
}
