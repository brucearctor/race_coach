//! Coaching cue priority queue with deduplication and rate limiting.
//!
//! The priority queue ensures that:
//! 1. Higher priority cues are spoken first
//! 2. Per-corner cooldowns prevent spamming the same feedback
//! 3. Cue types are deduplicated within a time window
//! 4. Maximum queue depth prevents memory growth

use std::collections::HashMap;

use crate::types::{CoachingCue, CueType};

/// Configuration for the priority queue.
#[derive(Debug, Clone)]
pub struct PriorityQueueConfig {
    /// Max pending cues in the queue.
    pub max_queue_depth: usize,
    /// Cooldown in frames before the same (corner, cue_type) can fire again.
    pub per_corner_cooldown_frames: u32,
    /// Cooldown in frames before the same cue_type can fire again (global).
    pub per_type_cooldown_frames: u32,
}

impl Default for PriorityQueueConfig {
    fn default() -> Self {
        Self {
            max_queue_depth: 8,
            per_corner_cooldown_frames: 75, // ~3 seconds at 25 Hz
            per_type_cooldown_frames: 25,   // ~1 second at 25 Hz
        }
    }
}

/// Key for per-corner cooldown tracking.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct CooldownKey {
    cue_type: CueType,
    corner_number: Option<u32>,
}

/// Priority queue for coaching cues.
pub struct PriorityQueue {
    /// Pending cues, sorted by priority on drain.
    pending: Vec<CoachingCue>,
    /// Remaining cooldown frames for each (type, corner) pair.
    cooldowns: HashMap<CooldownKey, u32>,
    /// Configuration.
    config: PriorityQueueConfig,
}

impl PriorityQueue {
    pub fn new() -> Self {
        Self {
            pending: Vec::new(),
            cooldowns: HashMap::new(),
            config: PriorityQueueConfig::default(),
        }
    }

    pub fn with_config(config: PriorityQueueConfig) -> Self {
        Self {
            pending: Vec::new(),
            cooldowns: HashMap::new(),
            config,
        }
    }

    /// Update configuration at runtime without clearing the queue.
    pub fn update_config(&mut self, config: PriorityQueueConfig) {
        self.config = config;
    }

    /// Attempt to enqueue a cue. Returns false if blocked by cooldown or queue full.
    pub fn enqueue(&mut self, cue: CoachingCue) -> bool {
        let key = CooldownKey {
            cue_type: cue.cue_type,
            corner_number: cue.corner_number,
        };

        // Check cooldown
        if let Some(remaining) = self.cooldowns.get(&key) {
            if *remaining > 0 {
                return false;
            }
        }

        // Check queue depth
        if self.pending.len() >= self.config.max_queue_depth {
            // If queue is full, only admit if higher priority than lowest
            if let Some(lowest) = self.pending.iter().min_by_key(|c| c.priority) {
                if cue.priority <= lowest.priority {
                    return false;
                }
                // Remove the lowest priority cue to make room
                let lowest_idx = self
                    .pending
                    .iter()
                    .position(|c| c.priority == lowest.priority)
                    .unwrap();
                self.pending.remove(lowest_idx);
            }
        }

        // Set cooldown
        let cooldown = if cue.corner_number.is_some() {
            self.config.per_corner_cooldown_frames
        } else {
            self.config.per_type_cooldown_frames
        };
        self.cooldowns.insert(key, cooldown);

        self.pending.push(cue);
        true
    }

    /// Drain all pending cues, sorted by priority (highest first).
    pub fn drain(&mut self) -> Vec<CoachingCue> {
        let mut cues = std::mem::take(&mut self.pending);
        // Sort by priority descending (Critical > High > Medium > Low)
        cues.sort_by_key(|c| std::cmp::Reverse(c.priority));
        cues
    }

    /// Take the single highest-priority pending cue (if any).
    pub fn take_highest(&mut self) -> Option<CoachingCue> {
        if self.pending.is_empty() {
            return None;
        }

        let max_idx = self
            .pending
            .iter()
            .enumerate()
            .max_by_key(|(_, c)| c.priority)
            .map(|(i, _)| i)
            .unwrap();

        Some(self.pending.remove(max_idx))
    }

    /// Tick all cooldowns by one frame. Call once per process_frame().
    pub fn tick(&mut self) {
        self.cooldowns.retain(|_, remaining| {
            *remaining = remaining.saturating_sub(1);
            *remaining > 0
        });
    }

    /// Reset all cooldowns and clear pending cues.
    pub fn reset(&mut self) {
        self.pending.clear();
        self.cooldowns.clear();
    }

    /// Number of pending cues.
    pub fn len(&self) -> usize {
        self.pending.len()
    }

    /// Whether the queue is empty.
    pub fn is_empty(&self) -> bool {
        self.pending.is_empty()
    }

    // ── Debug HUD accessors ──────────────────────────────────────────

    /// Current number of pending cues in the queue.
    pub fn queue_depth(&self) -> usize {
        self.pending.len()
    }

    /// Configured maximum queue depth.
    pub fn max_depth(&self) -> usize {
        self.config.max_queue_depth
    }

    /// Active cooldowns with frames remaining, for the debug overlay.
    ///
    /// Sorted by cue type for deterministic display order at 25 Hz.
    pub fn active_cooldowns(&self) -> Vec<crate::types::CooldownInfo> {
        let mut cooldowns: Vec<_> = self
            .cooldowns
            .iter()
            .filter(|(_, remaining)| **remaining > 0)
            .map(|(key, remaining)| crate::types::CooldownInfo {
                cue_type: format!("{:?}", key.cue_type),
                frames_remaining: *remaining,
            })
            .collect();
        cooldowns.sort_by(|a, b| a.cue_type.cmp(&b.cue_type));
        cooldowns
    }
}

impl Default for PriorityQueue {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::CuePriority;

    fn make_cue(cue_type: CueType, priority: CuePriority, corner: Option<u32>) -> CoachingCue {
        CoachingCue {
            cue_type,
            message: format!("{cue_type:?} cue"),
            priority,
            corner_number: corner,
            delta_seconds: None,
            distance_delta_m: None,
        }
    }

    #[test]
    fn test_enqueue_and_drain() {
        let mut q = PriorityQueue::new();
        q.enqueue(make_cue(CueType::Speed, CuePriority::Low, Some(1)));
        q.enqueue(make_cue(CueType::Braking, CuePriority::High, Some(2)));
        q.enqueue(make_cue(CueType::General, CuePriority::Medium, None));

        let cues = q.drain();
        assert_eq!(cues.len(), 3);
        // Highest priority first
        assert_eq!(cues[0].priority, CuePriority::High);
        assert_eq!(cues[1].priority, CuePriority::Medium);
        assert_eq!(cues[2].priority, CuePriority::Low);
    }

    #[test]
    fn test_cooldown_blocks_same_corner_type() {
        let mut q = PriorityQueue::new();
        let cue = make_cue(CueType::Speed, CuePriority::Medium, Some(1));

        assert!(q.enqueue(cue.clone()));
        // Same corner + type should be blocked
        assert!(!q.enqueue(cue));
    }

    #[test]
    fn test_cooldown_expires_after_ticks() {
        let config = PriorityQueueConfig {
            per_corner_cooldown_frames: 3,
            per_type_cooldown_frames: 2,
            max_queue_depth: 8,
        };
        let mut q = PriorityQueue::with_config(config);
        let cue = make_cue(CueType::Speed, CuePriority::Medium, Some(1));

        assert!(q.enqueue(cue.clone()));
        q.drain(); // clear pending

        // Still on cooldown
        q.tick();
        assert!(!q.enqueue(cue.clone()));
        q.tick();
        assert!(!q.enqueue(cue.clone()));

        // Cooldown expired
        q.tick();
        assert!(q.enqueue(cue));
    }

    #[test]
    fn test_max_queue_depth() {
        let config = PriorityQueueConfig {
            max_queue_depth: 2,
            per_corner_cooldown_frames: 75,
            per_type_cooldown_frames: 25,
        };
        let mut q = PriorityQueue::with_config(config);

        q.enqueue(make_cue(CueType::Speed, CuePriority::Low, Some(1)));
        q.enqueue(make_cue(CueType::Braking, CuePriority::Medium, Some(2)));

        // Queue full — low priority cue should be rejected
        assert!(!q.enqueue(make_cue(CueType::General, CuePriority::Low, None)));

        // High priority should evict the lowest
        assert!(q.enqueue(make_cue(CueType::GForce, CuePriority::High, Some(3))));
        assert_eq!(q.len(), 2);
    }

    #[test]
    fn test_take_highest() {
        let mut q = PriorityQueue::new();
        q.enqueue(make_cue(CueType::Speed, CuePriority::Low, Some(1)));
        q.enqueue(make_cue(CueType::Braking, CuePriority::Critical, Some(2)));

        let cue = q.take_highest().unwrap();
        assert_eq!(cue.priority, CuePriority::Critical);
        assert_eq!(q.len(), 1);
    }

    #[test]
    fn test_reset_clears_everything() {
        let mut q = PriorityQueue::new();
        q.enqueue(make_cue(CueType::Speed, CuePriority::Low, Some(1)));
        q.reset();

        assert!(q.is_empty());
        // Should be able to enqueue same type again (cooldown cleared)
        assert!(q.enqueue(make_cue(CueType::Speed, CuePriority::Low, Some(1))));
    }
}
