//! Delta-T — running time differential vs reference lap.
//!
//! Computes how far ahead or behind the driver is compared to the reference
//! lap at the same track distance. Positive = behind, negative = ahead.

use crate::registry::{AnalysisContext, AnalysisResult, DataRequirement, TelemetryAnalyzer};
use crate::math::filters::ExponentialFilter;

/// Delta-T analyzer.
pub struct DeltaT {
    enabled: bool,
    elapsed_ms: u64,
    start_timestamp_ms: Option<u64>,
    trend_filter: ExponentialFilter,
    last_delta: f64,
}

impl DeltaT {
    pub fn new() -> Self {
        Self {
            enabled: true,
            elapsed_ms: 0,
            start_timestamp_ms: None,
            trend_filter: ExponentialFilter::new(0.3),
            last_delta: 0.0,
        }
    }
}

impl Default for DeltaT {
    fn default() -> Self {
        Self::new()
    }
}

impl TelemetryAnalyzer for DeltaT {
    fn id(&self) -> &str {
        "delta_t"
    }

    fn display_name(&self) -> &str {
        "Delta-T"
    }

    fn is_enabled(&self) -> bool {
        self.enabled
    }

    fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    fn requirements(&self) -> &[DataRequirement] {
        &[DataRequirement::Gps, DataRequirement::ReferenceLap]
    }

    fn analyze(&mut self, ctx: &AnalysisContext) -> Vec<AnalysisResult> {
        // Track elapsed time from session start
        let timestamp = ctx.current.timestamp_ms;
        if self.start_timestamp_ms.is_none() {
            self.start_timestamp_ms = Some(timestamp);
        }
        self.elapsed_ms = timestamp.saturating_sub(self.start_timestamp_ms.unwrap_or(timestamp));
        let _elapsed_s = self.elapsed_ms as f64 / 1000.0;

        // If we have a reference frame, compute delta
        if let (Some(ref_frame), Some(_ref_distance)) =
            (ctx.reference_frame, ctx.reference_lap_distance_m)
        {
            // Reference frame has a timestamp representing "where you should be"
            // at this track distance if you were driving the reference pace.
            // We need to know the reference elapsed time at this distance.
            //
            // For now, use speed-based estimation:
            // At the same distance, if reference speed > current speed, driver is falling behind.
            let current_speed = ctx.current.speed_kmh as f64 / 3.6;
            let ref_speed = ref_frame.speed_kmh as f64 / 3.6;

            if current_speed > 0.5 && ref_speed > 0.5 {
                // Time to cover a small segment at each speed
                // Accumulate the difference
                let speed_ratio = ref_speed / current_speed;
                let dt_contribution = ctx.dt * (1.0 - speed_ratio);
                let delta = self.last_delta + dt_contribution;
                self.last_delta = delta;

                let trend = self.trend_filter.update(dt_contribution) as f32;

                return vec![AnalysisResult::DeltaT {
                    seconds: delta,
                    trend,
                }];
            }
        }

        // No reference data available
        vec![AnalysisResult::DeltaT {
            seconds: self.last_delta,
            trend: 0.0,
        }]
    }

    fn reset(&mut self) {
        self.elapsed_ms = 0;
        self.start_timestamp_ms = None;
        self.trend_filter.reset();
        self.last_delta = 0.0;
    }
}
