//! Coaching API — the primary interface between Dart and the Rust analysis engine.
//!
//! This module contains all the functions that Dart calls via flutter_rust_bridge.
//! The session lifecycle:
//!
//! 1. `create_session()` — initialize with track config + analysis config
//! 2. `process_frame()` — called 25x/sec with raw telemetry → returns FrameOutput
//! 3. `set_reference_lap()` — load reference lap frames for comparison
//! 4. `calibrate_imu()` — run IMU bias calibration from stationary samples
//! 5. `destroy_session()` — cleanup

use std::collections::HashSet;
use std::sync::Mutex;

use crate::braking::corner_speed::CornerSpeedComparison;
use crate::braking::g_onset::BrakingOnsetDetector;
use crate::calibration::imu_bias::{self, ImuCalibrator};
use crate::coaching::cue_engine::CueEngine;
use crate::distance::speed_integrated::SpeedIntegratedDistance;
use crate::dynamics::friction_circle::FrictionCircle;
use crate::reference::reference_lap::ReferenceLap;
use crate::registry::{AnalysisContext, AnalysisRegistry, AnalysisResult, DataRequirement};
use crate::timing::delta_t::DeltaT;
use crate::timing::sector_timer::SectorTimer;
use crate::types::*;

// ─── Session state ────────────────────────────────────────────────────────

/// Internal session state managed by the engine.
struct Session {
    registry: AnalysisRegistry,
    cue_engine: CueEngine,
    reference_lap: Option<ReferenceLap>,
    imu_bias: Option<ImuBias>,
    #[allow(dead_code)] // Used for corner config when setting reference laps
    config: SessionConfig,
    previous_input: Option<TelemetryInput>,
    previous_timestamp_ms: Option<u64>,
    track_distance_m: f64,
    current_sector: u32,
}

/// Global session storage. We use a Mutex<Option<Session>> because
/// flutter_rust_bridge needs thread-safe access.
static SESSION: Mutex<Option<Session>> = Mutex::new(None);

// ─── Session lifecycle ────────────────────────────────────────────────────

/// Create a new analysis session with the given configuration.
///
/// Call this once at session start. Registers all analyzers and
/// auto-configures based on available data.
pub fn create_session(config: SessionConfig) -> bool {
    let mut registry = AnalysisRegistry::new();

    // Register all analyzers
    registry.register(Box::new(SpeedIntegratedDistance::new()));

    let mut sector_timer = SectorTimer::new();
    sector_timer.configure(
        config.track.sector_splits.clone(),
        config.track.finish_line_a,
        config.track.finish_line_b,
    );
    registry.register(Box::new(sector_timer));

    registry.register(Box::new(DeltaT::new()));
    registry.register(Box::new(BrakingOnsetDetector::new()));
    registry.register(Box::new(FrictionCircle::new()));

    // Register corner speed comparison with track corners
    let mut corner_speed = CornerSpeedComparison::new();
    corner_speed.configure(config.track.corners.clone());
    registry.register(Box::new(corner_speed));

    // Apply user config
    registry.apply_config(&config.analysis);

    // Auto-disable analyzers whose data requirements aren't met
    let mut available = HashSet::new();
    available.insert(DataRequirement::Gps);
    available.insert(DataRequirement::Imu);
    if !config.track.sector_splits.is_empty() {
        available.insert(DataRequirement::SectorLines);
    }
    if !config.track.corners.is_empty() {
        available.insert(DataRequirement::Corners);
    }
    if !config.track.centerline.is_empty() {
        available.insert(DataRequirement::Centerline);
    }
    registry.configure_for_data(&available);

    let session = Session {
        registry,
        cue_engine: CueEngine::new(),
        reference_lap: None,
        imu_bias: None,
        config,
        previous_input: None,
        previous_timestamp_ms: None,
        track_distance_m: 0.0,
        current_sector: 0,
    };

    let mut guard = SESSION.lock().unwrap();
    *guard = Some(session);
    true
}

/// Destroy the current session and free resources.
pub fn destroy_session() {
    let mut guard = SESSION.lock().unwrap();
    *guard = None;
}

// ─── Hot path (called 25x/sec) ────────────────────────────────────────────

/// Process one telemetry frame and return analysis results.
///
/// This is the hot path — called 25 times per second. Must complete
/// well within the 40ms frame budget (typically <100μs).
pub fn process_frame(input: TelemetryInput) -> FrameOutput {
    let mut guard = SESSION.lock().unwrap();
    let session = match guard.as_mut() {
        Some(s) => s,
        None => return FrameOutput::default(),
    };

    // Apply IMU bias correction
    let corrected_input = if let Some(bias) = &session.imu_bias {
        let (g_lat, g_long, g_vert) = imu_bias::apply_bias(
            input.g_lateral,
            input.g_longitudinal,
            input.g_vertical,
            bias,
        );
        TelemetryInput {
            g_lateral: g_lat,
            g_longitudinal: g_long,
            g_vertical: g_vert,
            ..input
        }
    } else {
        input
    };

    // Compute dt
    let dt = match session.previous_timestamp_ms {
        Some(prev_ts) => (corrected_input.timestamp_ms as f64 - prev_ts as f64) / 1000.0,
        None => 0.0,
    };

    // Lookup reference frame at current distance
    let reference_frame_data;
    let reference_frame = if let Some(ref ref_lap) = session.reference_lap {
        reference_frame_data = ref_lap.lookup(session.track_distance_m);
        reference_frame_data.as_ref()
    } else {
        None
    };

    let reference_lap_distance_m = session.reference_lap.as_ref().map(|r| r.total_distance_m);

    // Build analysis context
    let ctx = AnalysisContext {
        current: &corrected_input,
        previous: session.previous_input.as_ref(),
        dt,
        track_distance_m: session.track_distance_m,
        reference_frame,
        reference_lap_distance_m,
    };

    // Run all enabled analyzers
    let results = session.registry.process_frame(&ctx);

    // Build output from results
    let mut output = FrameOutput {
        current_sector: session.current_sector,
        ..FrameOutput::default()
    };

    for result in &results {
        match result {
            AnalysisResult::Distance(d) => {
                session.track_distance_m = *d;
                output.track_distance_m = *d;
                // Compute lap distance percentage
                if let Some(total) = reference_lap_distance_m {
                    if total > 0.0 {
                        output.lap_distance_pct = (*d / total).min(1.0) as f32;
                    }
                }
            }
            AnalysisResult::SectorCrossing {
                sector,
                sector_time_s,
            } => {
                session.current_sector = sector + 1;
                output.current_sector = session.current_sector;
                output.sector_delta = Some(*sector_time_s);
            }
            AnalysisResult::DeltaT { seconds, trend } => {
                output.delta_t_seconds = *seconds;
                output.delta_t_trend = *trend;
            }
            AnalysisResult::BrakingUpdate(state) => {
                output.braking_state = *state;
            }
            AnalysisResult::FrictionUpdate(state) => {
                output.friction_circle = *state;
                output.grip_utilization = state.utilization;
            }
            AnalysisResult::Cue(_) => {
                // Handled by CueEngine below
            }
        }
    }

    // Run the cue engine — it processes all results and applies
    // heuristics + priority queue to produce the final coaching cues.
    output.coaching_cues = session.cue_engine.process_results(&results);

    // Update state for next frame
    session.previous_input = Some(corrected_input);
    session.previous_timestamp_ms = Some(input.timestamp_ms);

    output
}

// ─── Reference lap ────────────────────────────────────────────────────────

/// Load a reference lap from raw telemetry frames.
///
/// Frames must be in chronological order. The engine indexes them by
/// speed-integrated distance for O(log n) lookup during process_frame().
pub fn set_reference_lap(frames: Vec<TelemetryInput>, lap_time_s: f64) {
    let reference = ReferenceLap::from_frames(&frames, lap_time_s);

    let mut guard = SESSION.lock().unwrap();
    if let Some(session) = guard.as_mut() {
        // Enable delta-T analyzer now that we have a reference
        session.reference_lap = Some(reference);

        // Mark ReferenceLap as available for analyzers that need it
        // (This could trigger auto-enable of delta_t if it was disabled)
    }
}

/// Clear the loaded reference lap.
pub fn clear_reference_lap() {
    let mut guard = SESSION.lock().unwrap();
    if let Some(session) = guard.as_mut() {
        session.reference_lap = None;
    }
}

/// Check if a reference lap is loaded.
pub fn has_reference_lap() -> bool {
    let guard = SESSION.lock().unwrap();
    guard
        .as_ref()
        .map(|s| s.reference_lap.is_some())
        .unwrap_or(false)
}

// ─── Configuration ────────────────────────────────────────────────────────

/// Update the analysis configuration (enable/disable individual analyzers).
pub fn set_analysis_config(config: AnalysisConfig) {
    let mut guard = SESSION.lock().unwrap();
    if let Some(session) = guard.as_mut() {
        session.registry.apply_config(&config);
    }
}

/// Get the list of all registered analyzers and their enabled state.
pub fn list_analyzers() -> Vec<AnalyzerInfo> {
    let guard = SESSION.lock().unwrap();
    match guard.as_ref() {
        Some(session) => session
            .registry
            .list_analyzers()
            .into_iter()
            .map(|(id, enabled)| AnalyzerInfo {
                id: id.to_string(),
                enabled,
            })
            .collect(),
        None => Vec::new(),
    }
}

// ─── IMU Calibration ──────────────────────────────────────────────────────

/// Run IMU bias calibration from stationary samples.
///
/// Collects the provided samples, computes the average bias, and
/// applies it to the current session. Returns the computed bias.
pub fn calibrate_imu(samples: Vec<ImuSample>) -> Option<ImuBias> {
    let mut calibrator = ImuCalibrator::new();
    for sample in &samples {
        calibrator.add_sample(sample.g_lateral, sample.g_longitudinal, sample.g_vertical);
    }

    let bias = calibrator.compute_bias()?;

    // Apply to session
    let mut guard = SESSION.lock().unwrap();
    if let Some(session) = guard.as_mut() {
        session.imu_bias = Some(bias);
    }

    Some(bias)
}

/// Reset the lap (distance back to zero, reset analyzers, keep reference).
pub fn reset_lap() {
    let mut guard = SESSION.lock().unwrap();
    if let Some(session) = guard.as_mut() {
        session.track_distance_m = 0.0;
        session.current_sector = 0;
        session.registry.reset_all();
    }
}

// ─── Types for the API ────────────────────────────────────────────────────

/// Info about a registered analyzer (returned by list_analyzers).
#[derive(Debug, Clone)]
pub struct AnalyzerInfo {
    pub id: String,
    pub enabled: bool,
}

/// Raw IMU sample for calibration.
#[derive(Debug, Clone, Copy)]
pub struct ImuSample {
    pub g_lateral: f32,
    pub g_longitudinal: f32,
    pub g_vertical: f32,
}
