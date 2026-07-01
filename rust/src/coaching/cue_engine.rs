//! Coaching cue decision engine.
//!
//! Takes analysis results from the registry and decides what coaching cues
//! to generate. The engine applies heuristics:
//!
//! - **Braking**: "Brake earlier" / "Brake later" based on onset distance vs reference
//! - **Corner speed**: delegated to CornerSpeedComparison analyzer (emits Cue results)
//! - **Friction circle**: "Coasting detected" / "Smooth the inputs"
//! - **Delta-T**: "Gaining time" / "Losing time" at large deltas
//!
//! All cues are routed through the PriorityQueue for rate limiting.

use crate::coaching::priority::{PriorityQueue, PriorityQueueConfig};
use crate::registry::AnalysisResult;
use crate::types::{
    BrakingState, CoachingCue, CueConfig, CuePriority, CueType, FrictionCircleState,
};

/// Thresholds for generating coaching cues.
#[derive(Debug, Clone)]
pub struct CueEngineConfig {
    /// Delta-T threshold (seconds) to trigger a "gaining/losing time" cue.
    pub delta_t_threshold_s: f64,
    /// Grip utilization below this triggers a "coasting" cue.
    pub coasting_threshold: f32,
    /// Grip utilization above this triggers a "smooth inputs" cue.
    pub over_driving_threshold: f32,
    /// Braking onset delta (meters) to trigger "brake earlier/later" cue.
    pub braking_delta_threshold_m: f32,
}

impl Default for CueEngineConfig {
    fn default() -> Self {
        Self {
            delta_t_threshold_s: 0.5,
            coasting_threshold: 0.15,
            over_driving_threshold: 0.95,
            braking_delta_threshold_m: 5.0,
        }
    }
}

/// Accumulated analysis state from the current frame.
#[derive(Debug, Default)]
pub struct FrameAnalysis {
    pub delta_t_seconds: f64,
    pub delta_t_trend: f32,
    pub braking: BrakingState,
    pub friction: FrictionCircleState,
    /// Cues emitted directly by analyzers (e.g., CornerSpeedComparison).
    pub direct_cues: Vec<CoachingCue>,
}

/// Cue engine — converts analysis results into coaching cues.
pub struct CueEngine {
    config: CueEngineConfig,
    queue: PriorityQueue,
    cue_config: CueConfig,
    /// Track whether we already announced a braking cue this zone.
    braking_cue_emitted: bool,
    /// Track previous braking state for edge detection.
    was_braking: bool,
}

impl CueEngine {
    pub fn new() -> Self {
        Self {
            config: CueEngineConfig::default(),
            queue: PriorityQueue::new(),
            cue_config: CueConfig::default(),
            braking_cue_emitted: false,
            was_braking: false,
        }
    }

    pub fn with_config(config: CueEngineConfig) -> Self {
        Self {
            config,
            queue: PriorityQueue::new(),
            cue_config: CueConfig::default(),
            braking_cue_emitted: false,
            was_braking: false,
        }
    }

    /// Build a fully-configured engine from a [`CueConfig`].
    ///
    /// Extracts thresholds into [`CueEngineConfig`] and cooldowns into
    /// [`PriorityQueueConfig`] so a single source of truth drives everything.
    pub fn with_cue_config(cue_config: CueConfig) -> Self {
        let engine_config = CueEngineConfig {
            delta_t_threshold_s: cue_config.delta_t_threshold_s,
            coasting_threshold: cue_config.coasting_threshold,
            over_driving_threshold: cue_config.over_driving_threshold,
            braking_delta_threshold_m: cue_config.braking_delta_threshold_m,
        };
        let queue_config = PriorityQueueConfig {
            max_queue_depth: 8,
            per_corner_cooldown_frames: cue_config.per_corner_cooldown_frames(),
            per_type_cooldown_frames: cue_config.per_type_cooldown_frames(),
        };
        Self {
            config: engine_config,
            queue: PriorityQueue::with_config(queue_config),
            cue_config,
            braking_cue_emitted: false,
            was_braking: false,
        }
    }

    /// Update configuration at runtime without resetting engine state.
    pub fn apply_cue_config(&mut self, cue_config: &CueConfig) {
        self.config.delta_t_threshold_s = cue_config.delta_t_threshold_s;
        self.config.coasting_threshold = cue_config.coasting_threshold;
        self.config.over_driving_threshold = cue_config.over_driving_threshold;
        self.config.braking_delta_threshold_m = cue_config.braking_delta_threshold_m;

        let queue_config = PriorityQueueConfig {
            max_queue_depth: 8,
            per_corner_cooldown_frames: cue_config.per_corner_cooldown_frames(),
            per_type_cooldown_frames: cue_config.per_type_cooldown_frames(),
        };
        self.queue.update_config(queue_config);
        self.cue_config = cue_config.clone();
    }

    /// Process a batch of analysis results from one frame and return
    /// any coaching cues that should be spoken.
    pub fn process_results(&mut self, results: &[AnalysisResult]) -> Vec<CoachingCue> {
        // Tick cooldowns
        self.queue.tick();

        // Accumulate frame analysis
        let mut analysis = FrameAnalysis::default();
        for result in results {
            match result {
                AnalysisResult::DeltaT { seconds, trend } => {
                    analysis.delta_t_seconds = *seconds;
                    analysis.delta_t_trend = *trend;
                }
                AnalysisResult::BrakingUpdate(state) => {
                    analysis.braking = *state;
                }
                AnalysisResult::FrictionUpdate(state) => {
                    analysis.friction = *state;
                }
                AnalysisResult::Cue(cue) => {
                    analysis.direct_cues.push(cue.clone());
                }
                _ => {}
            }
        }

        // Generate cues from heuristics (gated by toggles)
        if self.cue_config.enable_braking_cues {
            self.evaluate_braking(&analysis);
        }
        self.evaluate_friction(&analysis);
        if self.cue_config.enable_delta_t_cues {
            self.evaluate_delta_t(&analysis);
        }

        // Enqueue direct cues from analyzers, filtered by toggle + verbosity
        let min_priority = self.cue_config.min_priority();
        for cue in analysis.direct_cues {
            if self.cue_config.is_cue_type_enabled(&cue.cue_type) && cue.priority >= min_priority {
                self.queue.enqueue(cue);
            }
        }

        // Update state
        self.was_braking = analysis.braking.is_braking;

        // Drain the queue (heuristic cues were already verbosity-filtered
        // before enqueue via enqueue_if_allowed, so no post-drain filter needed).
        self.queue.drain()
    }

    /// Evaluate braking onset delta vs reference.
    fn evaluate_braking(&mut self, analysis: &FrameAnalysis) {
        // Edge detection: just started braking
        if analysis.braking.is_braking && !self.was_braking {
            self.braking_cue_emitted = false;
        }

        // Just stopped braking — evaluate the braking zone
        if !analysis.braking.is_braking && self.was_braking && !self.braking_cue_emitted {
            if let Some(delta_m) = analysis.braking.reference_onset_delta_m {
                if delta_m.abs() > self.config.braking_delta_threshold_m {
                    let (message, priority) = if delta_m > 0.0 {
                        // Driver braked LATER than reference (positive delta = good?)
                        // Actually, positive delta_m means onset was further from corner
                        // Depends on convention. Let's say positive = braked earlier
                        (
                            format!("Brake {:.0} meters later", delta_m.abs()),
                            CuePriority::Medium,
                        )
                    } else {
                        (
                            format!("Brake {:.0} meters earlier", delta_m.abs()),
                            CuePriority::Medium,
                        )
                    };

                    self.enqueue_if_allowed(CoachingCue {
                        cue_type: CueType::Braking,
                        message,
                        priority,
                        corner_number: None,
                        delta_seconds: None,
                        distance_delta_m: Some(delta_m as f64),
                    });
                    self.braking_cue_emitted = true;
                }
            }
        }
    }

    /// Evaluate friction circle for coasting / over-driving.
    fn evaluate_friction(&mut self, analysis: &FrameAnalysis) {
        let util = analysis.friction.utilization;

        if self.cue_config.enable_coasting_cues
            && analysis.friction.is_coasting
            && util < self.config.coasting_threshold
        {
            self.enqueue_if_allowed(CoachingCue {
                cue_type: CueType::Coasting,
                message: "Coasting detected — maintain throttle or brake".to_string(),
                priority: CuePriority::Low,
                corner_number: None,
                delta_seconds: None,
                distance_delta_m: None,
            });
        }

        if self.cue_config.enable_grip_limit_cues && util > self.config.over_driving_threshold {
            self.enqueue_if_allowed(CoachingCue {
                cue_type: CueType::GripUtilization,
                message: "Smooth the inputs — near grip limit".to_string(),
                priority: CuePriority::High,
                corner_number: None,
                delta_seconds: None,
                distance_delta_m: None,
            });
        }
    }

    /// Evaluate delta-T for large gains or losses.
    fn evaluate_delta_t(&mut self, analysis: &FrameAnalysis) {
        let delta = analysis.delta_t_seconds;
        let threshold = self.config.delta_t_threshold_s;

        if delta.abs() > threshold {
            let (message, priority) = if delta < -threshold {
                // Ahead of reference — encouraging
                (
                    format!("Gaining {:.1} seconds", delta.abs()),
                    CuePriority::Low,
                )
            } else {
                // Behind reference
                (
                    format!("Losing {:.1} seconds", delta.abs()),
                    CuePriority::Low,
                )
            };

            self.enqueue_if_allowed(CoachingCue {
                cue_type: CueType::LapTime,
                message,
                priority,
                corner_number: None,
                delta_seconds: Some(delta),
                distance_delta_m: None,
            });
        }
    }

    /// Reset all state (new lap).
    pub fn reset(&mut self) {
        self.queue.reset();
        self.braking_cue_emitted = false;
        self.was_braking = false;
    }

    /// Enqueue a cue only if it passes the verbosity filter.
    ///
    /// This prevents filtered-out cues from consuming cooldowns, which would
    /// block future emissions of the same cue type.
    fn enqueue_if_allowed(&mut self, cue: CoachingCue) {
        let min_priority = self.cue_config.min_priority();
        if cue.priority >= min_priority {
            self.queue.enqueue(cue);
        }
    }
}

impl Default for CueEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::CueConfig;

    #[test]
    fn test_no_results_no_cues() {
        let mut engine = CueEngine::new();
        let cues = engine.process_results(&[]);
        assert!(cues.is_empty());
    }

    #[test]
    fn test_large_delta_t_generates_cue() {
        let cfg = CueConfig {
            verbosity: 2,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        let results = vec![AnalysisResult::DeltaT {
            seconds: 1.5,
            trend: 0.1,
        }];
        let cues = engine.process_results(&results);
        assert_eq!(cues.len(), 1);
        assert_eq!(cues[0].cue_type, CueType::LapTime);
        assert!(cues[0].message.contains("Losing"));
    }

    #[test]
    fn test_gaining_time_cue() {
        let cfg = CueConfig {
            verbosity: 2,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        let results = vec![AnalysisResult::DeltaT {
            seconds: -0.8,
            trend: -0.1,
        }];
        let cues = engine.process_results(&results);
        assert_eq!(cues.len(), 1);
        assert!(cues[0].message.contains("Gaining"));
    }

    #[test]
    fn test_small_delta_t_no_cue() {
        let mut engine = CueEngine::new();
        let results = vec![AnalysisResult::DeltaT {
            seconds: 0.2,
            trend: 0.0,
        }];
        let cues = engine.process_results(&results);
        assert!(cues.is_empty());
    }

    #[test]
    fn test_over_driving_cue() {
        let mut engine = CueEngine::new();
        let results = vec![AnalysisResult::FrictionUpdate(FrictionCircleState {
            g_total: 1.8,
            g_max: 1.9,
            utilization: 0.97,
            is_coasting: false,
            is_trail_braking: false,
        })];
        let cues = engine.process_results(&results);
        assert_eq!(cues.len(), 1);
        assert_eq!(cues[0].cue_type, CueType::GripUtilization);
        assert_eq!(cues[0].priority, CuePriority::High);
    }

    #[test]
    fn test_coasting_cue() {
        let cfg = CueConfig {
            verbosity: 2,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        let results = vec![AnalysisResult::FrictionUpdate(FrictionCircleState {
            g_total: 0.1,
            g_max: 1.5,
            utilization: 0.05,
            is_coasting: true,
            is_trail_braking: false,
        })];
        let cues = engine.process_results(&results);
        assert_eq!(cues.len(), 1);
        assert_eq!(cues[0].cue_type, CueType::Coasting);
    }

    #[test]
    fn test_braking_onset_cue() {
        let mut engine = CueEngine::new();

        // Start braking
        let start = vec![AnalysisResult::BrakingUpdate(BrakingState {
            is_braking: true,
            braking_g: 0.8,
            distance_since_onset: 0.0,
            reference_onset_delta_m: Some(8.0),
        })];
        engine.process_results(&start);

        // Stop braking — should generate cue
        let stop = vec![AnalysisResult::BrakingUpdate(BrakingState {
            is_braking: false,
            braking_g: 0.0,
            distance_since_onset: 0.0,
            reference_onset_delta_m: Some(8.0),
        })];
        let cues = engine.process_results(&stop);
        assert_eq!(cues.len(), 1);
        assert_eq!(cues[0].cue_type, CueType::Braking);
    }

    #[test]
    fn test_direct_cues_pass_through() {
        let mut engine = CueEngine::new();
        let results = vec![AnalysisResult::Cue(CoachingCue {
            cue_type: CueType::Speed,
            message: "Turn 3: carry 5 more speed".to_string(),
            priority: CuePriority::Medium,
            corner_number: Some(3),
            delta_seconds: None,
            distance_delta_m: None,
        })];
        let cues = engine.process_results(&results);
        assert_eq!(cues.len(), 1);
        assert_eq!(cues[0].corner_number, Some(3));
    }

    #[test]
    fn test_reset_clears_state() {
        let mut engine = CueEngine::new();
        // Start braking
        engine.process_results(&[AnalysisResult::BrakingUpdate(BrakingState {
            is_braking: true,
            braking_g: 0.8,
            distance_since_onset: 0.0,
            reference_onset_delta_m: Some(10.0),
        })]);

        engine.reset();

        // After reset, was_braking should be false
        assert!(!engine.was_braking);
        assert!(!engine.braking_cue_emitted);
    }

    // ── CueConfig tests ──────────────────────────────────────────────

    #[test]
    fn test_verbosity_low_filters_medium_and_low() {
        let cfg = CueConfig {
            verbosity: 0,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        // Delta-T of 1.5 s triggers a LapTime cue with Low priority
        let results = vec![AnalysisResult::DeltaT {
            seconds: 1.5,
            trend: 0.1,
        }];
        let cues = engine.process_results(&results);
        // Low-priority cue should be filtered at verbosity 0
        assert!(
            cues.is_empty(),
            "Low-priority delta-T cue should be filtered at verbosity 0"
        );
    }

    #[test]
    fn test_verbosity_high_passes_all() {
        let cfg = CueConfig {
            verbosity: 2,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        let results = vec![AnalysisResult::DeltaT {
            seconds: 1.5,
            trend: 0.1,
        }];
        let cues = engine.process_results(&results);
        assert_eq!(cues.len(), 1, "All cues should pass at verbosity 2");
    }

    #[test]
    fn test_disabled_braking_cue_not_emitted() {
        let cfg = CueConfig {
            enable_braking_cues: false,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);

        // Start braking
        engine.process_results(&[AnalysisResult::BrakingUpdate(BrakingState {
            is_braking: true,
            braking_g: 0.8,
            distance_since_onset: 0.0,
            reference_onset_delta_m: Some(8.0),
        })]);

        // Stop braking — should NOT generate cue because braking is disabled
        let cues = engine.process_results(&[AnalysisResult::BrakingUpdate(BrakingState {
            is_braking: false,
            braking_g: 0.0,
            distance_since_onset: 0.0,
            reference_onset_delta_m: Some(8.0),
        })]);
        assert!(cues.is_empty(), "Braking cue should not emit when disabled");
    }

    #[test]
    fn test_disabled_coasting_cue_not_emitted() {
        let cfg = CueConfig {
            enable_coasting_cues: false,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        let results = vec![AnalysisResult::FrictionUpdate(FrictionCircleState {
            g_total: 0.1,
            g_max: 1.5,
            utilization: 0.05,
            is_coasting: true,
            is_trail_braking: false,
        })];
        let cues = engine.process_results(&results);
        assert!(
            cues.is_empty(),
            "Coasting cue should not emit when disabled"
        );
    }

    #[test]
    fn test_custom_threshold_overrides_default() {
        let cfg = CueConfig {
            delta_t_threshold_s: 2.0,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        // 1.5s delta is below the 2.0s custom threshold
        let results = vec![AnalysisResult::DeltaT {
            seconds: 1.5,
            trend: 0.1,
        }];
        let cues = engine.process_results(&results);
        assert!(
            cues.is_empty(),
            "1.5s delta should not trigger with 2.0s threshold"
        );
    }

    #[test]
    fn test_cooldown_from_seconds_conversion() {
        let cfg = CueConfig {
            per_corner_cooldown_s: 5.0,
            per_type_cooldown_s: 2.0,
            ..CueConfig::default()
        };
        assert_eq!(cfg.per_corner_cooldown_frames(), 125);
        assert_eq!(cfg.per_type_cooldown_frames(), 50);
    }

    #[test]
    fn test_apply_cue_config_updates_engine() {
        let cfg = CueConfig {
            verbosity: 2,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        // Default threshold is 0.5 — 1.5s should trigger
        let results = vec![AnalysisResult::DeltaT {
            seconds: 1.5,
            trend: 0.1,
        }];
        let cues = engine.process_results(&results);
        assert_eq!(cues.len(), 1);

        // Now raise the threshold mid-session
        let new_cfg = CueConfig {
            verbosity: 2,
            delta_t_threshold_s: 2.0,
            ..CueConfig::default()
        };
        engine.apply_cue_config(&new_cfg);

        // Reset cooldowns so the cue type can fire again
        engine.reset();
        let cues = engine.process_results(&results);
        assert!(
            cues.is_empty(),
            "After threshold increase, 1.5s should not trigger"
        );
    }

    #[test]
    fn test_cue_config_default_matches_current_behavior() {
        // Default CueConfig engine should behave identically to CueEngine::new()
        let mut default_engine = CueEngine::new();
        let mut config_engine = CueEngine::with_cue_config(CueConfig::default());

        let results = vec![AnalysisResult::DeltaT {
            seconds: 1.5,
            trend: 0.1,
        }];
        let default_cues = default_engine.process_results(&results);
        let config_cues = config_engine.process_results(&results);
        assert_eq!(default_cues.len(), config_cues.len());
    }

    #[test]
    fn test_direct_cue_filtered_by_toggle() {
        let cfg = CueConfig {
            enable_corner_speed_cues: false,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);
        let results = vec![AnalysisResult::Cue(CoachingCue {
            cue_type: CueType::Speed,
            message: "Turn 3: carry 5 more speed".to_string(),
            priority: CuePriority::Medium,
            corner_number: Some(3),
            delta_seconds: None,
            distance_delta_m: None,
        })];
        let cues = engine.process_results(&results);
        assert!(
            cues.is_empty(),
            "Speed cue should be filtered when corner_speed disabled"
        );
    }

    #[test]
    fn test_heuristic_cue_filtered_by_verbosity_does_not_consume_cooldown() {
        // Regression: at verbosity 0, a low-priority heuristic delta-T cue
        // should NOT be enqueued at all, so it shouldn't set a cooldown that
        // blocks the same cue type when verbosity is later raised.
        let cfg = CueConfig {
            verbosity: 0,
            ..CueConfig::default()
        };
        let mut engine = CueEngine::with_cue_config(cfg);

        // Emit a low-priority delta-T cue at verbosity 0 → should be filtered
        let results = vec![AnalysisResult::DeltaT {
            seconds: 1.5,
            trend: 0.1,
        }];
        let cues = engine.process_results(&results);
        assert!(
            cues.is_empty(),
            "Low-priority cue should be filtered at verbosity 0"
        );

        // Now raise verbosity to 2 (High) WITHOUT resetting cooldowns
        let new_cfg = CueConfig {
            verbosity: 2,
            ..CueConfig::default()
        };
        engine.apply_cue_config(&new_cfg);

        // Tick enough frames to clear any cooldown (if one was erroneously set)
        for _ in 0..100 {
            engine.queue.tick();
        }

        // Same delta-T cue should now pass at high verbosity
        let cues = engine.process_results(&results);
        assert!(
            !cues.is_empty(),
            "After raising verbosity, delta-T cue should emit (no stale cooldown)"
        );
    }
}
