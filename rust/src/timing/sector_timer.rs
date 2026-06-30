//! Sector timer — detects sector boundary crossings and tracks sector splits.
//!
//! Uses line segment intersection (finish line + sector split lines) to
//! detect when the car crosses a sector boundary, and records split times.

use crate::math::line_segment;
use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};
use crate::types::{LatLng, SectorSplit};

/// Sector timer analyzer.
pub struct SectorTimer {
    enabled: bool,
    sector_splits: Vec<SectorSplit>,
    finish_line: Option<(LatLng, LatLng)>,

    current_sector: u32,
    sector_start_time_ms: u64,
    previous_position: Option<LatLng>,
}

impl SectorTimer {
    pub fn new() -> Self {
        Self {
            enabled: true,
            sector_splits: Vec::new(),
            finish_line: None,
            current_sector: 0,
            sector_start_time_ms: 0,
            previous_position: None,
        }
    }

    /// Configure sector split lines and finish line.
    pub fn configure(&mut self, splits: Vec<SectorSplit>, finish_a: LatLng, finish_b: LatLng) {
        self.sector_splits = splits;
        self.finish_line = Some((finish_a, finish_b));
    }
}

impl Default for SectorTimer {
    fn default() -> Self {
        Self::new()
    }
}

impl TelemetryAnalyzer for SectorTimer {
    fn id(&self) -> &str {
        "sector_timer"
    }

    fn display_name(&self) -> &str {
        "Sector Timer"
    }

    fn is_enabled(&self) -> bool {
        self.enabled
    }

    fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    fn requirements(&self) -> &[DataRequirement] {
        &[DataRequirement::Gps, DataRequirement::SectorLines]
    }

    fn analyze(&mut self, ctx: &AnalysisContext) -> Vec<AnalysisResult> {
        let current_pos = LatLng {
            lat: ctx.current.latitude,
            lng: ctx.current.longitude,
        };

        let Some(prev_pos) = self.previous_position else {
            self.previous_position = Some(current_pos);
            self.sector_start_time_ms = ctx.current.timestamp_ms;
            return Vec::new();
        };

        self.previous_position = Some(current_pos);

        let mut results = Vec::new();

        // Check each sector split line for crossing
        for split in &self.sector_splits {
            let intersection = line_segment::segments_intersect(
                prev_pos,
                current_pos,
                split.point_a,
                split.point_b,
            );

            if intersection.intersects {
                let sector_time_ms = ctx
                    .current
                    .timestamp_ms
                    .saturating_sub(self.sector_start_time_ms);
                let sector_time_s = sector_time_ms as f64 / 1000.0;

                results.push(AnalysisResult::SectorCrossing {
                    sector: self.current_sector,
                    sector_time_s,
                });

                self.current_sector = split.sector_number;
                self.sector_start_time_ms = ctx.current.timestamp_ms;
            }
        }

        results
    }

    fn reset(&mut self) {
        self.current_sector = 0;
        self.sector_start_time_ms = 0;
        self.previous_position = None;
    }
}
