//! Haversine distance calculation for GPS coordinates.

use crate::types::LatLng;

/// Earth's mean radius in meters.
const EARTH_RADIUS_M: f64 = 6_371_000.0;

/// Calculate the great-circle distance between two GPS points in meters.
///
/// Uses the haversine formula, which is accurate for small and large distances.
pub fn distance_meters(a: LatLng, b: LatLng) -> f64 {
    let lat1 = a.lat.to_radians();
    let lat2 = b.lat.to_radians();
    let dlat = (b.lat - a.lat).to_radians();
    let dlng = (b.lng - a.lng).to_radians();

    let h = (dlat / 2.0).sin().powi(2) + lat1.cos() * lat2.cos() * (dlng / 2.0).sin().powi(2);

    EARTH_RADIUS_M * 2.0 * h.sqrt().asin()
}

/// Calculate the initial bearing from point `a` to point `b` in degrees (0-360).
pub fn bearing_degrees(a: LatLng, b: LatLng) -> f64 {
    let lat1 = a.lat.to_radians();
    let lat2 = b.lat.to_radians();
    let dlng = (b.lng - a.lng).to_radians();

    let y = dlng.sin() * lat2.cos();
    let x = lat1.cos() * lat2.sin() - lat1.sin() * lat2.cos() * dlng.cos();

    (y.atan2(x).to_degrees() + 360.0) % 360.0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_distance_same_point() {
        let p = LatLng {
            lat: 39.5383,
            lng: -122.3310,
        };
        assert!((distance_meters(p, p)).abs() < 1e-6);
    }

    #[test]
    fn test_distance_known_points() {
        // Thunderhill Raceway approximate start/finish to Turn 1 entry (~200m)
        let start = LatLng {
            lat: 39.5383,
            lng: -122.3310,
        };
        let t1_entry = LatLng {
            lat: 39.5390,
            lng: -122.3295,
        };
        let d = distance_meters(start, t1_entry);
        // Should be roughly 140-160m
        assert!(d > 100.0 && d < 250.0, "Distance was {d}m");
    }

    #[test]
    fn test_distance_symmetry() {
        let a = LatLng {
            lat: 39.5383,
            lng: -122.3310,
        };
        let b = LatLng {
            lat: 39.5400,
            lng: -122.3300,
        };
        let d_ab = distance_meters(a, b);
        let d_ba = distance_meters(b, a);
        assert!((d_ab - d_ba).abs() < 1e-6);
    }

    #[test]
    fn test_bearing_north() {
        let a = LatLng {
            lat: 39.0,
            lng: -122.0,
        };
        let b = LatLng {
            lat: 40.0,
            lng: -122.0,
        };
        let bearing = bearing_degrees(a, b);
        // Due north ≈ 0°
        assert!(bearing < 1.0 || bearing > 359.0, "Bearing was {bearing}°");
    }

    #[test]
    fn test_bearing_east() {
        let a = LatLng {
            lat: 39.0,
            lng: -122.0,
        };
        let b = LatLng {
            lat: 39.0,
            lng: -121.0,
        };
        let bearing = bearing_degrees(a, b);
        // Due east ≈ 90°
        assert!(
            (bearing - 90.0).abs() < 1.0,
            "Bearing was {bearing}°, expected ~90°"
        );
    }
}
