//! Trail braking analyzer.
//!
//! Detects trail braking technique (simultaneous cornering + braking) and
//! evaluates quality. Good trail braking shows a smooth, progressive
//! transfer from braking to cornering grip. Poor trail braking shows
//! abrupt transitions or excessive braking while cornering.
//!
//! Emits coaching cues when trail braking quality deviates from ideal.

use crate::math::filters::ExponentialFilter;
use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};
use crate::types::{CoachingCue, CuePriority, CueType};

/// Configuration for trail braking analysis.
#[derive(Debug, Clone, Copy)]
pub struct TrailBrakingConfig {
    /// Minimum lateral G to consider the driver is cornering.
    pub min_lateral_g: f32,
    /// Minimum longitudinal G (negative = braking) to consider braking.
    pub min_braking_g: f32,
    /// Trail braking quality score below this triggers a coaching cue.
    pub quality_threshold: f32,
    /// Smoothing for quality metric (0.0-1.0).
    pub smoothing_alpha: f64,
    /// Minimum frames in a trail braking zone before evaluating.
    pub min_zone_frames: u32,
    /// Cooldown frames after emitting a cue.
    pub cooldown_frames: u32,
}

impl Default for TrailBrakingConfig {
    fn default() -> Self {
        Self {
            min_lateral_g: 0.3,
            min_braking_g: 0.15,
            quality_threshold: 0.4,
            smoothing_alpha: 0.3,
            min_zone_frames: 5, // 200ms at 25 Hz
            cooldown_frames: 75,
        }
    }
}

/// Trail braking quality state.
#[derive(Debug, Clone, Copy, Default)]
pub struct TrailBrakingState {
    /// Whether currently in a trail braking zone.
    pub is_trail_braking: bool,
    /// Quality score 0.0-1.0 (1.0 = ideal smooth transfer).
    pub quality: f32,
    /// Duration of current trail braking zone in frames.
    pub zone_frames: u32,
}

/// Trail braking analyzer.
pub struct TrailBrakingAnalyzer {
    enabled: bool,
    config: TrailBrakingConfig,
    quality_filter: ExponentialFilter,
    state: TrailBrakingState,
    prev_braking_ratio: f32,
    cooldown_remaining: u32,
    cue_emitted: bool,
}

impl TrailBrakingAnalyzer {
    pub fn new() -> Self {
        Self::with_config(TrailBrakingConfig::default())
    }

    pub fn with_config(config: TrailBrakingConfig) -> Self {
        Self {
            enabled: false, // Disabled by default in AnalysisConfig
            config,
            quality_filter: ExponentialFilter::new(config.smoothing_alpha),
            state: TrailBrakingState::default(),
            prev_braking_ratio: 0.0,
            cooldown_remaining: 0,
            cue_emitted: false,
        }
    }
}

impl Default for TrailBrakingAnalyzer {
    fn default() -> Self {
        Self::new()
    }
}

impl TelemetryAnalyzer for TrailBrakingAnalyzer {
    fn id(&self) -> &str {
        "trail_braking"
    }

    fn display_name(&self) -> &str {
        "Trail Braking"
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

        let g_lat = ctx.current.g_lateral.abs();
        let g_long = -ctx.current.g_longitudinal; // Positive when braking

        let is_cornering = g_lat > self.config.min_lateral_g;
        let is_braking = g_long > self.config.min_braking_g;
        let is_trail_braking = is_cornering && is_braking;

        if is_trail_braking {
            self.state.zone_frames += 1;
            self.state.is_trail_braking = true;

            // Compute braking ratio: how much of total G is braking vs cornering
            let g_total = (g_lat * g_lat + g_long * g_long).sqrt();
            let braking_ratio = if g_total > 0.01 {
                g_long / g_total
            } else {
                0.0
            };

            // Quality: smoothness of the braking ratio transition.
            // Ideal trail braking progressively reduces braking_ratio from ~1.0
            // to 0.0. Large frame-to-frame changes indicate abruptness.
            let ratio_change = (braking_ratio - self.prev_braking_ratio).abs();
            // Lower change = higher quality. Map to 0-1 range.
            let frame_quality = (1.0 - ratio_change * 3.0).max(0.0);
            let smoothed = self.quality_filter.update(frame_quality as f64) as f32;
            self.state.quality = smoothed;
            self.prev_braking_ratio = braking_ratio;
        } else if self.state.is_trail_braking {
            // Just exited trail braking zone — evaluate
            self.state.is_trail_braking = false;

            if self.state.zone_frames >= self.config.min_zone_frames
                && !self.cue_emitted
                && self.cooldown_remaining == 0
                && self.state.quality < self.config.quality_threshold
            {
                results.push(AnalysisResult::Cue(CoachingCue {
                    cue_type: CueType::TrailBraking,
                    message: format!(
                        "Smooth the trail brake — quality {:.0}%",
                        self.state.quality * 100.0
                    ),
                    priority: CuePriority::Medium,
                    corner_number: None,
                    delta_seconds: None,
                    distance_delta_m: None,
                }));
                self.cue_emitted = true;
                self.cooldown_remaining = self.config.cooldown_frames;
            }

            // Reset zone tracking
            self.state.zone_frames = 0;
            self.state.quality = 0.0;
            self.prev_braking_ratio = 0.0;
            self.quality_filter.reset();
            self.cue_emitted = false;
        } else {
            self.prev_braking_ratio = 0.0;
        }

        results
    }

    fn reset(&mut self) {
        self.state = TrailBrakingState::default();
        self.prev_braking_ratio = 0.0;
        self.cooldown_remaining = 0;
        self.cue_emitted = false;
        self.quality_filter.reset();
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
            speed_kmh: 150.0,
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
    fn test_no_trail_braking_when_only_cornering() {
        let mut analyzer = TrailBrakingAnalyzer::new();
        analyzer.set_enabled(true);
        let input = make_input(0.8, 0.0); // Cornering only
        let results = analyzer.analyze(&make_ctx(&input));
        assert!(results.is_empty());
        assert!(!analyzer.state.is_trail_braking);
    }

    #[test]
    fn test_no_trail_braking_when_only_braking() {
        let mut analyzer = TrailBrakingAnalyzer::new();
        analyzer.set_enabled(true);
        let input = make_input(0.0, -0.8); // Braking only
        let results = analyzer.analyze(&make_ctx(&input));
        assert!(results.is_empty());
        assert!(!analyzer.state.is_trail_braking);
    }

    #[test]
    fn test_trail_braking_detected() {
        let mut analyzer = TrailBrakingAnalyzer::new();
        analyzer.set_enabled(true);
        let input = make_input(0.5, -0.4); // Cornering + braking
        analyzer.analyze(&make_ctx(&input));
        assert!(analyzer.state.is_trail_braking);
    }

    #[test]
    fn test_abrupt_transition_generates_cue() {
        let mut analyzer = TrailBrakingAnalyzer::with_config(TrailBrakingConfig {
            min_zone_frames: 2,
            quality_threshold: 0.5, // Moderate bar
            smoothing_alpha: 1.0,   // No smoothing
            min_lateral_g: 0.1,
            min_braking_g: 0.05,
            ..Default::default()
        });
        analyzer.set_enabled(true);

        // Abrupt trail braking: large changes between frames
        let frames = [
            make_input(0.5, -0.8), // Heavy braking + cornering
            make_input(0.5, -0.1), // Suddenly light braking
            make_input(0.5, -0.7), // Heavy again
        ];
        for f in &frames {
            analyzer.analyze(&make_ctx(f));
        }

        // Exit trail braking zone
        let exit = make_input(0.8, 0.0);
        let results = analyzer.analyze(&make_ctx(&exit));
        assert_eq!(results.len(), 1);
        match &results[0] {
            AnalysisResult::Cue(cue) => {
                assert_eq!(cue.cue_type, CueType::TrailBraking);
                assert!(cue.message.contains("Smooth"));
            }
            _ => panic!("Expected Cue"),
        }
    }

    #[test]
    fn test_smooth_transition_no_cue() {
        let mut analyzer = TrailBrakingAnalyzer::with_config(TrailBrakingConfig {
            min_zone_frames: 2,
            quality_threshold: 0.2, // Low bar
            smoothing_alpha: 1.0,
            min_lateral_g: 0.1,
            min_braking_g: 0.05,
            ..Default::default()
        });
        analyzer.set_enabled(true);

        // Smooth progressive trail brake — very small ratio changes
        let frames = [
            make_input(0.5, -0.50),
            make_input(0.5, -0.48),
            make_input(0.5, -0.46),
            make_input(0.5, -0.44),
        ];
        for f in &frames {
            analyzer.analyze(&make_ctx(f));
        }

        // Exit
        let exit = make_input(0.8, 0.0);
        let results = analyzer.analyze(&make_ctx(&exit));
        assert!(
            results.is_empty(),
            "Smooth trail brake should not trigger cue"
        );
    }

    #[test]
    fn test_reset_clears_state() {
        let mut analyzer = TrailBrakingAnalyzer::new();
        analyzer.set_enabled(true);
        analyzer.state.zone_frames = 10;
        analyzer.state.is_trail_braking = true;
        analyzer.reset();
        assert_eq!(analyzer.state.zone_frames, 0);
        assert!(!analyzer.state.is_trail_braking);
    }
}
