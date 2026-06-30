//! Signal processing filters for telemetry data.
//!
//! Moving average and low-pass filters for smoothing noisy IMU/GPS signals.

/// Simple moving average filter with a fixed window size.
#[derive(Debug, Clone)]
pub struct MovingAverage {
    buffer: Vec<f64>,
    index: usize,
    sum: f64,
    count: usize,
    capacity: usize,
}

impl MovingAverage {
    /// Create a new moving average filter with the given window size.
    pub fn new(window_size: usize) -> Self {
        assert!(window_size > 0, "Window size must be > 0");
        Self {
            buffer: vec![0.0; window_size],
            index: 0,
            sum: 0.0,
            count: 0,
            capacity: window_size,
        }
    }

    /// Add a new sample and return the current average.
    pub fn update(&mut self, value: f64) -> f64 {
        if self.count >= self.capacity {
            self.sum -= self.buffer[self.index];
        } else {
            self.count += 1;
        }

        self.buffer[self.index] = value;
        self.sum += value;
        self.index = (self.index + 1) % self.capacity;

        self.sum / self.count as f64
    }

    /// Get the current average without adding a new sample.
    pub fn current(&self) -> f64 {
        if self.count == 0 {
            0.0
        } else {
            self.sum / self.count as f64
        }
    }

    /// Reset the filter to its initial state.
    pub fn reset(&mut self) {
        self.buffer.fill(0.0);
        self.index = 0;
        self.sum = 0.0;
        self.count = 0;
    }
}

/// Exponential moving average (first-order low-pass filter).
///
/// Smoothing factor `alpha` controls responsiveness:
/// - alpha = 1.0: no filtering (output = input)
/// - alpha = 0.1: heavy filtering (slow response to changes)
///
/// Typical values for 25 Hz telemetry:
/// - 0.3–0.5 for G-force smoothing
/// - 0.1–0.2 for heavy smoothing (jerk analysis)
#[derive(Debug, Clone, Copy)]
pub struct ExponentialFilter {
    alpha: f64,
    value: f64,
    initialized: bool,
}

impl ExponentialFilter {
    /// Create a new exponential filter with the given smoothing factor.
    pub fn new(alpha: f64) -> Self {
        assert!((0.0..=1.0).contains(&alpha), "Alpha must be in [0.0, 1.0]");
        Self {
            alpha,
            value: 0.0,
            initialized: false,
        }
    }

    /// Add a new sample and return the filtered value.
    pub fn update(&mut self, input: f64) -> f64 {
        if !self.initialized {
            self.value = input;
            self.initialized = true;
        } else {
            self.value = self.alpha * input + (1.0 - self.alpha) * self.value;
        }
        self.value
    }

    /// Get the current filtered value.
    pub fn current(&self) -> f64 {
        self.value
    }

    /// Reset the filter.
    pub fn reset(&mut self) {
        self.value = 0.0;
        self.initialized = false;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_moving_average_basic() {
        let mut ma = MovingAverage::new(3);
        assert!((ma.update(1.0) - 1.0).abs() < 1e-10); // [1] → avg 1.0
        assert!((ma.update(2.0) - 1.5).abs() < 1e-10); // [1,2] → avg 1.5
        assert!((ma.update(3.0) - 2.0).abs() < 1e-10); // [1,2,3] → avg 2.0
        assert!((ma.update(4.0) - 3.0).abs() < 1e-10); // [2,3,4] → avg 3.0 (1 dropped)
    }

    #[test]
    fn test_moving_average_constant() {
        let mut ma = MovingAverage::new(5);
        for _ in 0..10 {
            let avg = ma.update(42.0);
            assert!((avg - 42.0).abs() < 1e-10);
        }
    }

    #[test]
    fn test_exponential_filter_passthrough() {
        let mut ef = ExponentialFilter::new(1.0);
        assert!((ef.update(5.0) - 5.0).abs() < 1e-10);
        assert!((ef.update(10.0) - 10.0).abs() < 1e-10);
    }

    #[test]
    fn test_exponential_filter_heavy_smoothing() {
        let mut ef = ExponentialFilter::new(0.1);
        ef.update(0.0);
        let val = ef.update(10.0);
        // With alpha=0.1: 0.1 * 10 + 0.9 * 0 = 1.0
        assert!((val - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_exponential_filter_converges() {
        let mut ef = ExponentialFilter::new(0.5);
        for _ in 0..100 {
            ef.update(100.0);
        }
        // Should converge to 100.0
        assert!((ef.current() - 100.0).abs() < 0.01);
    }
}
