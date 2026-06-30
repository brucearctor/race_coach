//! Analyzer trait and registry for pluggable telemetry analysis.
//!
//! Every analysis method (distance, braking, friction circle, etc.) implements
//! the `TelemetryAnalyzer` trait. The `AnalysisRegistry` manages enabled
//! analyzers and runs them on each telemetry frame.

use crate::types::{AnalysisConfig, CoachingCue, TelemetryInput};
use std::collections::HashSet;

/// What data an analyzer requires to function.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum DataRequirement {
    Gps,
    Imu,
    Obd,
    Centerline,
    SectorLines,
    Corners,
    ReferenceLap,
}

/// Context provided to each analyzer on every frame.
pub struct AnalysisContext<'a> {
    /// Current telemetry frame (with bias correction applied).
    pub current: &'a TelemetryInput,
    /// Previous telemetry frame (None on first frame).
    pub previous: Option<&'a TelemetryInput>,
    /// Time delta since previous frame in seconds.
    pub dt: f64,
    /// Current accumulated track distance in meters.
    pub track_distance_m: f64,
    /// Reference frame at the same track distance (if reference lap loaded).
    pub reference_frame: Option<&'a TelemetryInput>,
    /// Reference lap total distance (for lap_distance_pct calculation).
    pub reference_lap_distance_m: Option<f64>,
}

/// Result from a single analyzer's processing.
#[derive(Debug)]
pub enum AnalysisResult {
    /// Updated track distance.
    Distance(f64),
    /// Sector boundary crossing detected.
    SectorCrossing { sector: u32, sector_time_s: f64 },
    /// Delta-T update.
    DeltaT { seconds: f64, trend: f32 },
    /// Braking state change.
    BrakingUpdate(crate::types::BrakingState),
    /// Friction circle update.
    FrictionUpdate(crate::types::FrictionCircleState),
    /// Coaching cue to be spoken.
    Cue(CoachingCue),
}

/// Trait for all analysis methods.
///
/// Implement this to add a new analysis capability (distance method,
/// braking detector, dynamics analyzer, etc.). Set `is_enabled` based
/// on `AnalysisConfig` and `requirements` to declare what data you need.
pub trait TelemetryAnalyzer: Send + Sync {
    /// Unique identifier for this analyzer.
    fn id(&self) -> &str;

    /// Human-readable display name.
    fn display_name(&self) -> &str;

    /// Whether this analyzer is currently enabled.
    fn is_enabled(&self) -> bool;

    /// Set enabled/disabled state.
    fn set_enabled(&mut self, enabled: bool);

    /// What data this analyzer requires to function.
    fn requirements(&self) -> &[DataRequirement];

    /// Process one telemetry frame. Returns zero or more results.
    fn analyze(&mut self, ctx: &AnalysisContext) -> Vec<AnalysisResult>;

    /// Reset internal state (e.g., on new lap or new session).
    fn reset(&mut self);
}

/// Registry of all analyzers. Manages lifecycle and dispatch.
pub struct AnalysisRegistry {
    analyzers: Vec<Box<dyn TelemetryAnalyzer>>,
}

impl AnalysisRegistry {
    /// Create an empty registry.
    pub fn new() -> Self {
        Self {
            analyzers: Vec::new(),
        }
    }

    /// Register a new analyzer.
    pub fn register(&mut self, analyzer: Box<dyn TelemetryAnalyzer>) {
        self.analyzers.push(analyzer);
    }

    /// Auto-configure analyzers based on available data.
    ///
    /// Disables any analyzer whose requirements aren't met by
    /// the available data sources.
    pub fn configure_for_data(&mut self, available: &HashSet<DataRequirement>) {
        for analyzer in &mut self.analyzers {
            let requirements_met = analyzer
                .requirements()
                .iter()
                .all(|r| available.contains(r));
            if !requirements_met && analyzer.is_enabled() {
                analyzer.set_enabled(false);
            }
        }
    }

    /// Apply an AnalysisConfig to enable/disable specific analyzers.
    pub fn apply_config(&mut self, config: &AnalysisConfig) {
        for analyzer in &mut self.analyzers {
            let enabled = match analyzer.id() {
                "speed_integrated_distance" => config.speed_integrated_distance,
                "centerline_projection" => config.centerline_projection,
                "sector_timer" => config.sector_timer,
                "delta_t" => config.delta_t,
                "braking_g_onset" => config.braking_g_onset,
                "corner_speed" => config.corner_speed,
                "friction_circle" => config.friction_circle,
                "trail_braking" => config.trail_braking,
                "jerk_analysis" => config.jerk_analysis,
                "speed_derivative" => config.speed_derivative,
                "combined_g" => config.combined_g,
                "heading_matching" => config.heading_matching,
                "curvature_matching" => config.curvature_matching,
                "energy_dissipation" => config.energy_dissipation,
                "braking_efficiency" => config.braking_efficiency,
                "throttle_analysis" => config.throttle_analysis,
                "brake_pressure" => config.brake_pressure,
                _ => analyzer.is_enabled(),
            };
            analyzer.set_enabled(enabled);
        }
    }

    /// Process one frame through all enabled analyzers.
    pub fn process_frame(&mut self, ctx: &AnalysisContext) -> Vec<AnalysisResult> {
        let mut results = Vec::new();
        for analyzer in &mut self.analyzers {
            if analyzer.is_enabled() {
                results.extend(analyzer.analyze(ctx));
            }
        }
        results
    }

    /// Reset all analyzers.
    pub fn reset_all(&mut self) {
        for analyzer in &mut self.analyzers {
            analyzer.reset();
        }
    }

    /// Get list of all registered analyzer IDs and their enabled state.
    pub fn list_analyzers(&self) -> Vec<(&str, bool)> {
        self.analyzers
            .iter()
            .map(|a| (a.id(), a.is_enabled()))
            .collect()
    }
}

impl Default for AnalysisRegistry {
    fn default() -> Self {
        Self::new()
    }
}
