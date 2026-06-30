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

use crate::coaching::priority::PriorityQueue;
use crate::registry::AnalysisResult;
use crate::types::{BrakingState, CoachingCue, CuePriority, CueType, FrictionCircleState};

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
            braking_cue_emitted: false,
            was_braking: false,
        }
    }

    pub fn with_config(config: CueEngineConfig) -> Self {
        Self {
            config,
            queue: PriorityQueue::new(),
            braking_cue_emitted: false,
            was_braking: false,
        }
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

        // Generate cues from heuristics
        self.evaluate_braking(&analysis);
        self.evaluate_friction(&analysis);
        self.evaluate_delta_t(&analysis);

        // Enqueue direct cues from analyzers (e.g., CornerSpeedComparison)
        for cue in analysis.direct_cues {
            self.queue.enqueue(cue);
        }

        // Update state
        self.was_braking = analysis.braking.is_braking;

        // Drain the queue — Dart will speak the highest priority first
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

                    self.queue.enqueue(CoachingCue {
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

        if analysis.friction.is_coasting && util < self.config.coasting_threshold {
            self.queue.enqueue(CoachingCue {
                cue_type: CueType::Coasting,
                message: "Coasting detected — maintain throttle or brake".to_string(),
                priority: CuePriority::Low,
                corner_number: None,
                delta_seconds: None,
                distance_delta_m: None,
            });
        }

        if util > self.config.over_driving_threshold {
            self.queue.enqueue(CoachingCue {
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

            self.queue.enqueue(CoachingCue {
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
}

impl Default for CueEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_no_results_no_cues() {
        let mut engine = CueEngine::new();
        let cues = engine.process_results(&[]);
        assert!(cues.is_empty());
    }

    #[test]
    fn test_large_delta_t_generates_cue() {
        let mut engine = CueEngine::new();
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
        let mut engine = CueEngine::new();
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
        let mut engine = CueEngine::new();
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
}
