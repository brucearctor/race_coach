//! Reference lap — loads, indexes by distance, and provides binary search
//! lookup to find the reference frame at any given track distance.

use crate::types::TelemetryInput;

/// A reference lap pre-indexed by distance for fast lookup.
pub struct ReferenceLap {
    /// Frames sorted by distance.
    frames: Vec<IndexedFrame>,
    /// Total lap time in seconds.
    pub lap_time_s: f64,
    /// Total lap distance in meters.
    pub total_distance_m: f64,
}

/// A reference frame with its pre-computed distance.
#[derive(Debug, Clone)]
struct IndexedFrame {
    distance_m: f64,
    frame: TelemetryInput,
}

impl ReferenceLap {
    /// Build a reference lap from raw telemetry frames.
    ///
    /// Computes distance by integrating speed over time (same method as
    /// SpeedIntegratedDistance). The frames must be in chronological order.
    pub fn from_frames(frames: &[TelemetryInput], lap_time_s: f64) -> Self {
        if frames.is_empty() {
            return Self {
                frames: Vec::new(),
                lap_time_s,
                total_distance_m: 0.0,
            };
        }

        let mut indexed = Vec::with_capacity(frames.len());
        let mut distance = 0.0;

        indexed.push(IndexedFrame {
            distance_m: 0.0,
            frame: frames[0],
        });

        for i in 1..frames.len() {
            let dt = (frames[i].timestamp_ms as f64 - frames[i - 1].timestamp_ms as f64) / 1000.0;
            if dt > 0.0 && dt < 2.0 {
                let v_prev = frames[i - 1].speed_kmh as f64 / 3.6;
                let v_curr = frames[i].speed_kmh as f64 / 3.6;
                distance += (v_prev + v_curr) / 2.0 * dt;
            }

            indexed.push(IndexedFrame {
                distance_m: distance,
                frame: frames[i],
            });
        }

        let total_distance_m = distance;

        Self {
            frames: indexed,
            lap_time_s,
            total_distance_m,
        }
    }

    /// Look up the reference frame at the given track distance.
    ///
    /// Uses binary search for O(log n) lookup. Interpolates between
    /// adjacent frames for smooth comparison.
    pub fn lookup(&self, distance_m: f64) -> Option<TelemetryInput> {
        if self.frames.is_empty() {
            return None;
        }

        if self.frames.len() == 1 {
            return Some(self.frames[0].frame);
        }

        // Clamp to valid range
        if distance_m <= self.frames[0].distance_m {
            return Some(self.frames[0].frame);
        }
        if distance_m >= self.frames.last().unwrap().distance_m {
            return Some(self.frames.last().unwrap().frame);
        }

        // Binary search for the insertion point
        let idx = match self
            .frames
            .binary_search_by(|f| f.distance_m.partial_cmp(&distance_m).unwrap())
        {
            Ok(i) => return Some(self.frames[i].frame), // Exact match
            Err(i) => i, // Insertion point: frames[i-1].distance < distance < frames[i].distance
        };

        // Interpolate between frames[idx-1] and frames[idx]
        let before = &self.frames[idx - 1];
        let after = &self.frames[idx];
        let segment_length = after.distance_m - before.distance_m;

        if segment_length < 1e-6 {
            return Some(after.frame);
        }

        let t = ((distance_m - before.distance_m) / segment_length).clamp(0.0, 1.0);
        Some(interpolate_frames(&before.frame, &after.frame, t))
    }

    /// Check if a reference lap is loaded.
    pub fn is_loaded(&self) -> bool {
        !self.frames.is_empty()
    }

    /// Number of frames in the reference lap.
    pub fn frame_count(&self) -> usize {
        self.frames.len()
    }
}

/// Linear interpolation between two telemetry frames.
fn interpolate_frames(a: &TelemetryInput, b: &TelemetryInput, t: f64) -> TelemetryInput {
    let lerp_f64 = |a: f64, b: f64| a + t * (b - a);
    let lerp_f32 = |a: f32, b: f32| a + (t as f32) * (b - a);

    TelemetryInput {
        timestamp_ms: (a.timestamp_ms as f64 + t * (b.timestamp_ms as f64 - a.timestamp_ms as f64))
            as u64,
        latitude: lerp_f64(a.latitude, b.latitude),
        longitude: lerp_f64(a.longitude, b.longitude),
        speed_kmh: lerp_f32(a.speed_kmh, b.speed_kmh),
        heading_deg: lerp_f32(a.heading_deg, b.heading_deg),
        altitude_m: lerp_f32(a.altitude_m, b.altitude_m),
        g_lateral: lerp_f32(a.g_lateral, b.g_lateral),
        g_longitudinal: lerp_f32(a.g_longitudinal, b.g_longitudinal),
        g_vertical: lerp_f32(a.g_vertical, b.g_vertical),
        satellites: a.satellites, // Not interpolatable
        hdop: lerp_f32(a.hdop, b.hdop),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_frame(timestamp_ms: u64, speed_kmh: f32) -> TelemetryInput {
        TelemetryInput {
            timestamp_ms,
            latitude: 39.5383,
            longitude: -122.3310,
            speed_kmh,
            heading_deg: 0.0,
            altitude_m: 100.0,
            g_lateral: 0.0,
            g_longitudinal: 0.0,
            g_vertical: 1.0,
            satellites: 12,
            hdop: 1.0,
        }
    }

    #[test]
    fn test_reference_lap_from_frames() {
        let frames: Vec<TelemetryInput> = (0..25)
            .map(|i| make_frame(i * 40, 100.0)) // 25 frames at 40ms, 100 km/h
            .collect();

        let lap = ReferenceLap::from_frames(&frames, 60.0);
        assert!(lap.is_loaded());
        assert_eq!(lap.frame_count(), 25);
        // 24 intervals × 0.04s × 27.78 m/s ≈ 26.67m
        assert!(
            (lap.total_distance_m - 26.67).abs() < 0.5,
            "Total distance was {}",
            lap.total_distance_m
        );
    }

    #[test]
    fn test_lookup_at_zero() {
        let frames: Vec<TelemetryInput> = (0..25)
            .map(|i| make_frame(i * 40, 100.0))
            .collect();

        let lap = ReferenceLap::from_frames(&frames, 60.0);
        let frame = lap.lookup(0.0).expect("Should find frame at distance 0");
        assert_eq!(frame.timestamp_ms, 0);
    }

    #[test]
    fn test_lookup_interpolation() {
        let frames = vec![
            make_frame(0, 100.0),
            make_frame(1000, 200.0), // 1 second later, faster
        ];

        let lap = ReferenceLap::from_frames(&frames, 60.0);
        let midpoint_distance = lap.total_distance_m / 2.0;
        let frame = lap.lookup(midpoint_distance).expect("Should find frame");
        // Speed should be between 100 and 200
        assert!(
            frame.speed_kmh > 100.0 && frame.speed_kmh < 200.0,
            "Expected speed between 100 and 200, got {}",
            frame.speed_kmh
        );
    }

    #[test]
    fn test_empty_reference_lap() {
        let lap = ReferenceLap::from_frames(&[], 0.0);
        assert!(!lap.is_loaded());
        assert!(lap.lookup(100.0).is_none());
    }
}
