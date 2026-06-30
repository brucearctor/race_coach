//! IMU bias calibration from stationary samples.
//!
//! When the car is stationary, G-forces should read (0, 0, 1g).
//! Any deviation is bias from sensor mounting angle or drift.
//! Collect samples while stationary and compute the average offset.

use crate::types::ImuBias;

/// Collect stationary IMU samples and compute bias.
pub struct ImuCalibrator {
    sum_lat: f64,
    sum_long: f64,
    sum_vert: f64,
    count: u32,
}

impl ImuCalibrator {
    pub fn new() -> Self {
        Self {
            sum_lat: 0.0,
            sum_long: 0.0,
            sum_vert: 0.0,
            count: 0,
        }
    }

    /// Add a stationary IMU sample.
    pub fn add_sample(&mut self, g_lateral: f32, g_longitudinal: f32, g_vertical: f32) {
        self.sum_lat += g_lateral as f64;
        self.sum_long += g_longitudinal as f64;
        self.sum_vert += g_vertical as f64;
        self.count += 1;
    }

    /// Compute the bias from collected samples.
    ///
    /// Returns None if no samples collected.
    /// Expected values at rest: (0, 0, ~1.0g).
    /// Bias = measured - expected.
    pub fn compute_bias(&self) -> Option<ImuBias> {
        if self.count == 0 {
            return None;
        }

        let n = self.count as f64;
        Some(ImuBias {
            lateral_g: (self.sum_lat / n) as f32,
            longitudinal_g: (self.sum_long / n) as f32,
            vertical_g: (self.sum_vert / n - 1.0) as f32, // Expected: 1g at rest
            sample_count: self.count,
        })
    }

    /// Reset and start collecting new samples.
    pub fn reset(&mut self) {
        self.sum_lat = 0.0;
        self.sum_long = 0.0;
        self.sum_vert = 0.0;
        self.count = 0;
    }

    /// Number of samples collected.
    pub fn sample_count(&self) -> u32 {
        self.count
    }
}

impl Default for ImuCalibrator {
    fn default() -> Self {
        Self::new()
    }
}

/// Apply IMU bias correction to raw G-force values.
pub fn apply_bias(
    g_lateral: f32,
    g_longitudinal: f32,
    g_vertical: f32,
    bias: &ImuBias,
) -> (f32, f32, f32) {
    (
        g_lateral - bias.lateral_g,
        g_longitudinal - bias.longitudinal_g,
        g_vertical - bias.vertical_g,
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calibration_zero_bias() {
        let mut cal = ImuCalibrator::new();
        // Perfect sensor: reads (0, 0, 1g) at rest
        for _ in 0..100 {
            cal.add_sample(0.0, 0.0, 1.0);
        }
        let bias = cal.compute_bias().unwrap();
        assert!((bias.lateral_g).abs() < 1e-6);
        assert!((bias.longitudinal_g).abs() < 1e-6);
        assert!((bias.vertical_g).abs() < 1e-6);
        assert_eq!(bias.sample_count, 100);
    }

    #[test]
    fn test_calibration_with_bias() {
        let mut cal = ImuCalibrator::new();
        // Sensor reads (0.02, -0.03, 1.05) at rest — biased
        for _ in 0..50 {
            cal.add_sample(0.02, -0.03, 1.05);
        }
        let bias = cal.compute_bias().unwrap();
        assert!((bias.lateral_g - 0.02).abs() < 1e-4);
        assert!((bias.longitudinal_g - (-0.03)).abs() < 1e-4);
        assert!((bias.vertical_g - 0.05).abs() < 1e-4);
    }

    #[test]
    fn test_apply_bias_correction() {
        let bias = ImuBias {
            lateral_g: 0.02,
            longitudinal_g: -0.03,
            vertical_g: 0.05,
            sample_count: 50,
        };

        let (lat, long, vert) = apply_bias(0.52, -0.83, 1.55, &bias);
        assert!((lat - 0.50).abs() < 1e-4);
        assert!((long - (-0.80)).abs() < 1e-4);
        assert!((vert - 1.50).abs() < 1e-4);
    }

    #[test]
    fn test_no_samples() {
        let cal = ImuCalibrator::new();
        assert!(cal.compute_bias().is_none());
    }
}
