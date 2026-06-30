//! Corner speed comparison analyzer.
//!
//! Compares the driver's minimum speed through each corner against the
//! reference lap's minimum speed at the same corner. Produces a coaching
//! cue when the difference exceeds a configurable threshold.
//!
//! Corner detection uses GPS proximity to corner apex points defined in
//! the track configuration.

use crate::math::haversine;
use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};
use crate::types::{CoachingCue, Corner, CuePriority, CueType, LatLng, TelemetryInput};

/// Configuration for corner speed comparison.
#[derive(Debug, Clone)]
pub struct CornerSpeedConfig {
    /// Radius in meters around apex to consider "in corner".
    pub apex_radius_m: f64,
    /// Minimum speed difference (km/h) to trigger a coaching cue.
    pub speed_threshold_kmh: f32,
    /// Cooldown: skip corner after generating a cue until this many frames pass.
    pub cooldown_frames: u32,
}

impl Default for CornerSpeedConfig {
    fn default() -> Self {
        Self {
            apex_radius_m: 50.0,
            speed_threshold_kmh: 3.0,
            cooldown_frames: 50, // ~2 seconds at 25 Hz
        }
    }
}

/// State tracking for a single corner.
#[derive(Debug, Clone)]
struct CornerState {
    /// The corner definition from track config.
    corner: Corner,
    /// Whether the driver is currently inside the apex zone.
    in_zone: bool,
    /// Minimum speed observed during the current zone traversal.
    min_speed_kmh: f32,
    /// Reference lap minimum speed at this corner (if known).
    reference_min_speed_kmh: Option<f32>,
    /// Frames remaining in cooldown (0 = ready).
    cooldown_remaining: u32,
    /// Whether a cue was already emitted for this pass.
    cue_emitted: bool,
}

/// Corner speed comparison analyzer.
///
/// For each corner in the track config, tracks whether the driver is near
/// the apex, records the minimum speed, and compares against the reference
/// lap to generate coaching cues.
pub struct CornerSpeedComparison {
    corners: Vec<CornerState>,
    config: CornerSpeedConfig,
    enabled: bool,
    /// Accumulated reference min speeds (set externally).
    reference_speeds: Vec<Option<f32>>,
}

impl CornerSpeedComparison {
    pub fn new() -> Self {
        Self {
            corners: Vec::new(),
            config: CornerSpeedConfig::default(),
            enabled: true,
            reference_speeds: Vec::new(),
        }
    }

    /// Configure with corner definitions from track config.
    pub fn configure(&mut self, corners: Vec<Corner>) {
        self.corners = corners
            .into_iter()
            .map(|c| CornerState {
                corner: c,
                in_zone: false,
                min_speed_kmh: f32::MAX,
                reference_min_speed_kmh: None,
                cooldown_remaining: 0,
                cue_emitted: false,
            })
            .collect();
    }

    /// Set reference minimum speeds for each corner.
    /// These are computed from the reference lap during set_reference_lap().
    pub fn set_reference_speeds(&mut self, speeds: Vec<Option<f32>>) {
        for (i, speed) in speeds.iter().enumerate() {
            if i < self.corners.len() {
                self.corners[i].reference_min_speed_kmh = *speed;
            }
        }
        self.reference_speeds = speeds;
    }

    /// Compute reference min speeds by scanning reference lap frames
    /// for each corner's apex zone.
    pub fn compute_reference_speeds(&mut self, frames: &[TelemetryInput]) {
        let mut speeds: Vec<Option<f32>> = vec![None; self.corners.len()];

        for (i, cs) in self.corners.iter().enumerate() {
            let mut min_speed = f32::MAX;
            let mut found = false;

            for frame in frames {
                let pos = LatLng {
                    lat: frame.latitude,
                    lng: frame.longitude,
                };
                let dist = haversine::distance_meters(pos, cs.corner.apex);

                if dist < self.config.apex_radius_m {
                    min_speed = min_speed.min(frame.speed_kmh);
                    found = true;
                }
            }

            if found {
                speeds[i] = Some(min_speed);
            }
        }

        self.set_reference_speeds(speeds);
    }
}

impl TelemetryAnalyzer for CornerSpeedComparison {
    fn id(&self) -> &str {
        "corner_speed"
    }

    fn display_name(&self) -> &str {
        "Corner Speed Comparison"
    }

    fn is_enabled(&self) -> bool {
        self.enabled
    }

    fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    fn requirements(&self) -> &[DataRequirement] {
        &[DataRequirement::Gps, DataRequirement::Corners]
    }

    fn analyze(&mut self, ctx: &AnalysisContext) -> Vec<AnalysisResult> {
        let mut results = Vec::new();
        let pos = LatLng {
            lat: ctx.current.latitude,
            lng: ctx.current.longitude,
        };

        for cs in &mut self.corners {
            // Tick cooldown
            if cs.cooldown_remaining > 0 {
                cs.cooldown_remaining -= 1;
            }

            let dist = haversine::distance_meters(pos, cs.corner.apex);
            let in_zone = dist < self.config.apex_radius_m;

            if in_zone {
                // Track minimum speed while in the apex zone
                cs.min_speed_kmh = cs.min_speed_kmh.min(ctx.current.speed_kmh);

                if !cs.in_zone {
                    // Entering the zone
                    cs.in_zone = true;
                    cs.cue_emitted = false;
                }
            } else if cs.in_zone {
                // Just left the corner zone — evaluate
                cs.in_zone = false;

                if !cs.cue_emitted && cs.cooldown_remaining == 0 {
                    if let Some(ref_speed) = cs.reference_min_speed_kmh {
                        let diff = cs.min_speed_kmh - ref_speed;

                        if diff.abs() > self.config.speed_threshold_kmh {
                            let (message, priority) = if diff > 0.0 {
                                // Driver carried MORE speed than reference — good!
                                (
                                    format!(
                                        "Turn {}: {:.0} faster through",
                                        cs.corner.number,
                                        diff.abs()
                                    ),
                                    CuePriority::Low,
                                )
                            } else {
                                // Driver was SLOWER than reference
                                (
                                    format!(
                                        "Turn {}: carry {:.0} more speed",
                                        cs.corner.number,
                                        diff.abs()
                                    ),
                                    CuePriority::Medium,
                                )
                            };

                            results.push(AnalysisResult::Cue(CoachingCue {
                                cue_type: CueType::Speed,
                                message,
                                priority,
                                corner_number: Some(cs.corner.number),
                                delta_seconds: None,
                                distance_delta_m: None,
                            }));

                            cs.cue_emitted = true;
                            cs.cooldown_remaining = self.config.cooldown_frames;
                        }
                    }
                }

                // Reset min speed for next pass
                cs.min_speed_kmh = f32::MAX;
            }
        }

        results
    }

    fn reset(&mut self) {
        for cs in &mut self.corners {
            cs.in_zone = false;
            cs.min_speed_kmh = f32::MAX;
            cs.cooldown_remaining = 0;
            cs.cue_emitted = false;
        }
    }
}

impl Default for CornerSpeedComparison {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::TelemetryInput;

    fn make_input(lat: f64, lng: f64, speed: f32) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms: 0,
            latitude: lat,
            longitude: lng,
            speed_kmh: speed,
            heading_deg: 0.0,
            altitude_m: 0.0,
            g_lateral: 0.0,
            g_longitudinal: 0.0,
            g_vertical: 1.0,
            satellites: 10,
            hdop: 1.0,
        }
    }

    fn make_corner(number: u32, lat: f64, lng: f64) -> Corner {
        Corner {
            number,
            name: format!("Turn {number}"),
            entry: LatLng {
                lat: lat + 0.0005,
                lng,
            },
            apex: LatLng { lat, lng },
            exit: LatLng {
                lat: lat - 0.0005,
                lng,
            },
        }
    }

    fn make_ctx<'a>(
        current: &'a TelemetryInput,
        previous: Option<&'a TelemetryInput>,
    ) -> AnalysisContext<'a> {
        AnalysisContext {
            current,
            previous,
            dt: 0.04,
            track_distance_m: 0.0,
            reference_frame: None,
            reference_lap_distance_m: None,
        }
    }

    #[test]
    fn test_no_corners_no_output() {
        let mut analyzer = CornerSpeedComparison::new();
        let input = make_input(37.0, -122.0, 100.0);
        let ctx = make_ctx(&input, None);
        let results = analyzer.analyze(&ctx);
        assert!(results.is_empty());
    }

    #[test]
    fn test_corner_speed_slower_than_reference() {
        let mut analyzer = CornerSpeedComparison::new();
        analyzer.configure(vec![make_corner(1, 37.0, -122.0)]);
        analyzer.set_reference_speeds(vec![Some(100.0)]);

        // Enter corner zone at slower speed
        let in_corner = make_input(37.0, -122.0, 90.0);
        let ctx = make_ctx(&in_corner, None);
        let results = analyzer.analyze(&ctx);
        assert!(results.is_empty()); // Still in zone, no cue yet

        // Exit corner zone
        let out_corner = make_input(37.01, -122.0, 120.0);
        let ctx = make_ctx(&out_corner, Some(&in_corner));
        let results = analyzer.analyze(&ctx);

        // Should get a coaching cue for being slower
        assert_eq!(results.len(), 1);
        match &results[0] {
            AnalysisResult::Cue(cue) => {
                assert_eq!(cue.cue_type, CueType::Speed);
                assert_eq!(cue.priority, CuePriority::Medium);
                assert_eq!(cue.corner_number, Some(1));
                assert!(cue.message.contains("carry"));
                assert!(cue.message.contains("10")); // 10 km/h difference
            }
            _ => panic!("Expected Cue result"),
        }
    }

    #[test]
    fn test_corner_speed_faster_than_reference() {
        let mut analyzer = CornerSpeedComparison::new();
        analyzer.configure(vec![make_corner(1, 37.0, -122.0)]);
        analyzer.set_reference_speeds(vec![Some(90.0)]);

        // Enter corner zone at faster speed
        let in_corner = make_input(37.0, -122.0, 100.0);
        let ctx = make_ctx(&in_corner, None);
        analyzer.analyze(&ctx);

        // Exit corner zone
        let out_corner = make_input(37.01, -122.0, 120.0);
        let ctx = make_ctx(&out_corner, Some(&in_corner));
        let results = analyzer.analyze(&ctx);

        assert_eq!(results.len(), 1);
        match &results[0] {
            AnalysisResult::Cue(cue) => {
                assert_eq!(cue.priority, CuePriority::Low);
                assert!(cue.message.contains("faster"));
            }
            _ => panic!("Expected Cue result"),
        }
    }

    #[test]
    fn test_within_threshold_no_cue() {
        let mut analyzer = CornerSpeedComparison::new();
        analyzer.configure(vec![make_corner(1, 37.0, -122.0)]);
        analyzer.set_reference_speeds(vec![Some(100.0)]);

        // Enter corner at speed within threshold (default 3 km/h)
        let in_corner = make_input(37.0, -122.0, 98.0);
        let ctx = make_ctx(&in_corner, None);
        analyzer.analyze(&ctx);

        // Exit corner zone
        let out_corner = make_input(37.01, -122.0, 120.0);
        let ctx = make_ctx(&out_corner, Some(&in_corner));
        let results = analyzer.analyze(&ctx);

        // No cue — within threshold
        assert!(results.is_empty());
    }

    #[test]
    fn test_cooldown_prevents_repeated_cue() {
        let mut analyzer = CornerSpeedComparison::new();
        let config = CornerSpeedConfig {
            cooldown_frames: 5,
            ..CornerSpeedConfig::default()
        };
        analyzer.config = config;
        analyzer.configure(vec![make_corner(1, 37.0, -122.0)]);
        analyzer.set_reference_speeds(vec![Some(100.0)]);

        // First pass — should get cue
        let in1 = make_input(37.0, -122.0, 85.0);
        analyzer.analyze(&make_ctx(&in1, None));
        let out1 = make_input(37.01, -122.0, 120.0);
        let r1 = analyzer.analyze(&make_ctx(&out1, Some(&in1)));
        assert_eq!(r1.len(), 1);

        // Second pass immediately — cooldown should prevent cue
        let in2 = make_input(37.0, -122.0, 85.0);
        analyzer.analyze(&make_ctx(&in2, Some(&out1)));
        let out2 = make_input(37.01, -122.0, 120.0);
        let r2 = analyzer.analyze(&make_ctx(&out2, Some(&in2)));
        assert!(r2.is_empty(), "Should be on cooldown");
    }

    #[test]
    fn test_no_reference_no_cue() {
        let mut analyzer = CornerSpeedComparison::new();
        analyzer.configure(vec![make_corner(1, 37.0, -122.0)]);
        // No reference speeds set

        let in_corner = make_input(37.0, -122.0, 85.0);
        analyzer.analyze(&make_ctx(&in_corner, None));
        let out_corner = make_input(37.01, -122.0, 120.0);
        let results = analyzer.analyze(&make_ctx(&out_corner, Some(&in_corner)));

        assert!(results.is_empty(), "No reference = no cue");
    }

    #[test]
    fn test_reset_clears_state() {
        let mut analyzer = CornerSpeedComparison::new();
        analyzer.configure(vec![make_corner(1, 37.0, -122.0)]);
        analyzer.set_reference_speeds(vec![Some(100.0)]);

        // Enter zone
        let in_corner = make_input(37.0, -122.0, 85.0);
        analyzer.analyze(&make_ctx(&in_corner, None));

        // Reset
        analyzer.reset();

        // State should be cleared
        assert!(!analyzer.corners[0].in_zone);
        assert_eq!(analyzer.corners[0].min_speed_kmh, f32::MAX);
    }

    #[test]
    fn test_compute_reference_speeds() {
        let mut analyzer = CornerSpeedComparison::new();
        analyzer.configure(vec![make_corner(1, 37.0, -122.0)]);

        // Reference lap frames — some near apex, some not
        let frames = vec![
            make_input(37.001, -122.0, 120.0), // approaching
            make_input(37.0, -122.0, 95.0),    // at apex — this is the min
            make_input(37.0, -122.0, 98.0),    // still near apex
            make_input(36.999, -122.0, 110.0), // leaving
        ];

        analyzer.compute_reference_speeds(&frames);
        assert_eq!(analyzer.corners[0].reference_min_speed_kmh, Some(95.0));
    }
}
