//! Line segment intersection and point-to-segment projection.
//!
//! Used for finish line crossing detection, sector split detection,
//! and centerline projection.

use crate::types::LatLng;

/// Result of a line segment intersection test.
#[derive(Debug, Clone, Copy)]
pub struct IntersectionResult {
    /// Whether the segments intersect.
    pub intersects: bool,
    /// Parameter t along segment AB (0.0 = A, 1.0 = B). Only valid if `intersects`.
    pub t: f64,
    /// Parameter u along segment CD (0.0 = C, 1.0 = D). Only valid if `intersects`.
    pub u: f64,
}

/// Test whether two line segments AB and CD intersect.
///
/// Uses the standard parametric method:
/// - Segment 1: P = A + t(B - A), t ∈ [0, 1]
/// - Segment 2: Q = C + u(D - C), u ∈ [0, 1]
///
/// Segments intersect iff both t and u are in [0, 1].
pub fn segments_intersect(a: LatLng, b: LatLng, c: LatLng, d: LatLng) -> IntersectionResult {
    let denominator = (b.lat - a.lat) * (d.lng - c.lng) - (b.lng - a.lng) * (d.lat - c.lat);

    // Parallel or coincident
    if denominator.abs() < 1e-14 {
        return IntersectionResult {
            intersects: false,
            t: 0.0,
            u: 0.0,
        };
    }

    let t = ((c.lat - a.lat) * (d.lng - c.lng) - (c.lng - a.lng) * (d.lat - c.lat)) / denominator;

    let u = -((b.lat - a.lat) * (c.lng - a.lng) - (b.lng - a.lng) * (c.lat - a.lat)) / denominator;

    IntersectionResult {
        intersects: (0.0..=1.0).contains(&t) && (0.0..=1.0).contains(&u),
        t,
        u,
    }
}

/// Result of projecting a point onto a line segment.
#[derive(Debug, Clone, Copy)]
pub struct ProjectionResult {
    /// The projected point on the segment.
    pub projected: LatLng,
    /// Parameter along the segment (0.0 = start, 1.0 = end). Clamped to [0, 1].
    pub t: f64,
    /// Perpendicular distance from the point to the segment (in coordinate units).
    pub distance_sq: f64,
}

/// Project a point onto a line segment.
///
/// Returns the closest point on segment AB to point P, along with the
/// parameter t (clamped to [0, 1]) and the squared distance.
pub fn project_point_onto_segment(p: LatLng, a: LatLng, b: LatLng) -> ProjectionResult {
    let ab_lat = b.lat - a.lat;
    let ab_lng = b.lng - a.lng;
    let ap_lat = p.lat - a.lat;
    let ap_lng = p.lng - a.lng;

    let ab_len_sq = ab_lat * ab_lat + ab_lng * ab_lng;

    // Degenerate segment (A == B)
    if ab_len_sq < 1e-20 {
        let dist_sq = ap_lat * ap_lat + ap_lng * ap_lng;
        return ProjectionResult {
            projected: a,
            t: 0.0,
            distance_sq: dist_sq,
        };
    }

    // Parameter t along AB, clamped to [0, 1]
    let t = ((ap_lat * ab_lat + ap_lng * ab_lng) / ab_len_sq).clamp(0.0, 1.0);

    let projected = LatLng {
        lat: a.lat + t * ab_lat,
        lng: a.lng + t * ab_lng,
    };

    let dp_lat = p.lat - projected.lat;
    let dp_lng = p.lng - projected.lng;
    let distance_sq = dp_lat * dp_lat + dp_lng * dp_lng;

    ProjectionResult {
        projected,
        t,
        distance_sq,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn latlng(lat: f64, lng: f64) -> LatLng {
        LatLng { lat, lng }
    }

    #[test]
    fn test_segments_intersect_crossing() {
        // X pattern
        let result = segments_intersect(
            latlng(0.0, 0.0),
            latlng(1.0, 1.0),
            latlng(0.0, 1.0),
            latlng(1.0, 0.0),
        );
        assert!(result.intersects);
        assert!((result.t - 0.5).abs() < 1e-10);
        assert!((result.u - 0.5).abs() < 1e-10);
    }

    #[test]
    fn test_segments_no_intersection() {
        // Parallel horizontal segments
        let result = segments_intersect(
            latlng(0.0, 0.0),
            latlng(1.0, 0.0),
            latlng(0.0, 1.0),
            latlng(1.0, 1.0),
        );
        assert!(!result.intersects);
    }

    #[test]
    fn test_segments_t_shape_no_cross() {
        // Segments that would intersect if extended but don't actually
        let result = segments_intersect(
            latlng(0.0, 0.0),
            latlng(0.4, 0.4),
            latlng(0.0, 1.0),
            latlng(1.0, 0.0),
        );
        assert!(!result.intersects);
    }

    #[test]
    fn test_project_midpoint() {
        let p = latlng(0.5, 1.0);
        let a = latlng(0.0, 0.0);
        let b = latlng(1.0, 0.0);
        let result = project_point_onto_segment(p, a, b);
        assert!((result.t - 0.5).abs() < 1e-10);
        assert!((result.projected.lat - 0.5).abs() < 1e-10);
        assert!((result.projected.lng - 0.0).abs() < 1e-10);
    }

    #[test]
    fn test_project_before_segment() {
        let p = latlng(-1.0, 0.0);
        let a = latlng(0.0, 0.0);
        let b = latlng(1.0, 0.0);
        let result = project_point_onto_segment(p, a, b);
        assert!((result.t - 0.0).abs() < 1e-10, "t should clamp to 0.0");
    }

    #[test]
    fn test_project_after_segment() {
        let p = latlng(2.0, 0.0);
        let a = latlng(0.0, 0.0);
        let b = latlng(1.0, 0.0);
        let result = project_point_onto_segment(p, a, b);
        assert!((result.t - 1.0).abs() < 1e-10, "t should clamp to 1.0");
    }
}
