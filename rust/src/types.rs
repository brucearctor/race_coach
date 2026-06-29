//! Core types shared across the analysis engine.
//!
//! These types define the data crossing the FFI boundary (inputs from Dart,
//! outputs back to Dart) and internal analysis results.

/// Raw telemetry input — what Dart sends to Rust each frame (25 Hz).
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct TelemetryInput {
    pub timestamp_ms: u64,
    pub latitude: f64,
    pub longitude: f64,
    pub speed_kmh: f32,
    pub heading_deg: f32,
    pub altitude_m: f32,
    pub g_lateral: f32,
    pub g_longitudinal: f32,
    pub g_vertical: f32,
    pub satellites: u8,
    pub hdop: f32,
}

/// Complete output returned to Dart after processing one frame.
#[derive(Debug, Clone)]
pub struct FrameOutput {
    pub track_distance_m: f64,
    pub lap_distance_pct: f32,
    pub delta_t_seconds: f64,
    pub delta_t_trend: f32,
    pub coaching_cues: Vec<CoachingCue>,
    pub friction_circle: FrictionCircleState,
    pub braking_state: BrakingState,
    pub current_sector: u32,
    pub sector_delta: Option<f64>,
    pub grip_utilization: f32,
}

impl Default for FrameOutput {
    fn default() -> Self {
        Self {
            track_distance_m: 0.0,
            lap_distance_pct: 0.0,
            delta_t_seconds: 0.0,
            delta_t_trend: 0.0,
            coaching_cues: Vec::new(),
            friction_circle: FrictionCircleState::default(),
            braking_state: BrakingState::default(),
            current_sector: 0,
            sector_delta: None,
            grip_utilization: 0.0,
        }
    }
}

/// A coaching cue to be spoken via TTS.
#[derive(Debug, Clone)]
pub struct CoachingCue {
    pub cue_type: CueType,
    pub message: String,
    pub priority: CuePriority,
    pub corner_number: Option<u32>,
    pub delta_seconds: Option<f64>,
    pub distance_delta_m: Option<f64>,
}

/// Type of coaching cue.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum CueType {
    Braking,
    Throttle,
    Line,
    Speed,
    SectorTime,
    LapTime,
    GForce,
    General,
    Coasting,
    TrailBraking,
    GripUtilization,
    MlBraking,
    MlThrottle,
}

/// Priority level for coaching cues.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum CuePriority {
    Low = 0,
    Medium = 1,
    High = 2,
    Critical = 3,
}

/// Real-time friction circle state.
#[derive(Debug, Clone, Copy, Default)]
pub struct FrictionCircleState {
    pub g_total: f32,
    pub g_max: f32,
    pub utilization: f32,
    pub is_coasting: bool,
    pub is_trail_braking: bool,
}

/// Current braking state.
#[derive(Debug, Clone, Copy, Default)]
pub struct BrakingState {
    pub is_braking: bool,
    pub braking_g: f32,
    pub distance_since_onset: f32,
    pub reference_onset_delta_m: Option<f32>,
}

/// Configuration for which analyzers are enabled.
#[derive(Debug, Clone)]
pub struct AnalysisConfig {
    // Distance methods
    pub speed_integrated_distance: bool,
    pub centerline_projection: bool,

    // Timing
    pub sector_timer: bool,
    pub delta_t: bool,

    // Braking
    pub braking_g_onset: bool,
    pub corner_speed: bool,
    pub trail_braking: bool,
    pub jerk_analysis: bool,
    pub speed_derivative: bool,

    // Dynamics
    pub friction_circle: bool,
    pub combined_g: bool,

    // Stubs (future)
    pub heading_matching: bool,
    pub curvature_matching: bool,
    pub energy_dissipation: bool,
    pub braking_efficiency: bool,

    // OBD-II (future)
    pub throttle_analysis: bool,
    pub brake_pressure: bool,
}

impl Default for AnalysisConfig {
    fn default() -> Self {
        Self {
            // Enabled by default
            speed_integrated_distance: true,
            sector_timer: true,
            delta_t: true,
            braking_g_onset: true,
            corner_speed: true,
            friction_circle: true,

            // Disabled by default
            centerline_projection: false,
            trail_braking: false,
            jerk_analysis: false,
            speed_derivative: false,
            combined_g: false,
            heading_matching: false,
            curvature_matching: false,
            energy_dissipation: false,
            braking_efficiency: false,
            throttle_analysis: false,
            brake_pressure: false,
        }
    }
}

/// A GPS coordinate pair.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LatLng {
    pub lat: f64,
    pub lng: f64,
}

/// A corner/turn definition from the track configuration.
#[derive(Debug, Clone)]
pub struct Corner {
    pub number: u32,
    pub name: String,
    pub entry: LatLng,
    pub apex: LatLng,
    pub exit: LatLng,
}

/// A sector split line (two GPS points defining a line across the track).
#[derive(Debug, Clone, Copy)]
pub struct SectorSplit {
    pub sector_number: u32,
    pub point_a: LatLng,
    pub point_b: LatLng,
}

/// Track configuration provided at session start.
#[derive(Debug, Clone)]
pub struct TrackConfig {
    pub name: String,
    pub finish_line_a: LatLng,
    pub finish_line_b: LatLng,
    pub corners: Vec<Corner>,
    pub sector_splits: Vec<SectorSplit>,
    pub centerline: Vec<LatLng>,
    pub track_length_m: Option<f64>,
}

/// Session configuration for initializing the analysis engine.
#[derive(Debug, Clone)]
pub struct SessionConfig {
    pub track: TrackConfig,
    pub analysis: AnalysisConfig,
    pub use_mph: bool,
}

/// IMU bias correction from stationary calibration.
#[derive(Debug, Clone, Copy, Default)]
pub struct ImuBias {
    pub lateral_g: f32,
    pub longitudinal_g: f32,
    pub vertical_g: f32,
    pub sample_count: u32,
}
