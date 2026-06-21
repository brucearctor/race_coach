

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Result of a detected start/finish line crossing.
class LapCrossing {
  const LapCrossing({
    required this.timestamp,
    required this.lapTime,
    required this.lapNumber,
  });

  /// When the crossing was detected.
  final DateTime timestamp;

  /// Duration of the completed lap.
  final Duration lapTime;

  /// The lap number that was just completed (1-indexed).
  final int lapNumber;

  @override
  String toString() =>
      'LapCrossing(lap: $lapNumber, time: ${lapTime.inMilliseconds}ms)';
}

/// Detects lap completions by checking GPS positions against a
/// start/finish line segment using line-segment intersection math.
class LapDetector {
  /// The two endpoints of the finish line segment.
  LatLng? _finishA;
  LatLng? _finishB;

  /// Lap bookkeeping.
  int _lapCount = 0;
  DateTime? _lapStartTime;

  /// Minimum time between crossings to prevent double-triggers (seconds).
  static const double _minLapSeconds = 10.0;

  /// Whether a finish line has been configured.
  bool get hasFinishLine => _finishA != null && _finishB != null;

  /// Current lap number (0 if no lap has started).
  int get currentLap => _lapCount;

  /// Define the start/finish line as a segment between two GPS points.
  ///
  /// The two points should be on opposite sides of the track surface,
  /// creating a "gate" the car must cross.
  void setFinishLine(LatLng point1, LatLng point2) {
    _finishA = point1;
    _finishB = point2;
    _lapCount = 0;
    _lapStartTime = null;
  }

  /// Clear the finish line and reset lap state.
  void reset() {
    _finishA = null;
    _finishB = null;
    _lapCount = 0;
    _lapStartTime = null;
  }

  /// Check whether the path from [previous] to [current] crosses the
  /// finish line.
  ///
  /// Returns a [LapCrossing] if a crossing is detected, `null` otherwise.
  LapCrossing? checkCrossing(LatLng previous, LatLng current) {
    if (!hasFinishLine) return null;

    final crossed = _segmentsIntersect(
      previous.latitude,
      previous.longitude,
      current.latitude,
      current.longitude,
      _finishA!.latitude,
      _finishA!.longitude,
      _finishB!.latitude,
      _finishB!.longitude,
    );

    if (!crossed) return null;

    final now = DateTime.now();

    // First crossing → start the first lap timer.
    if (_lapStartTime == null) {
      _lapStartTime = now;
      _lapCount = 1;
      return null; // No completed lap yet, just started timing.
    }

    // Debounce: ignore crossings that happen too quickly.
    final elapsed = now.difference(_lapStartTime!);
    if (elapsed.inMilliseconds < (_minLapSeconds * 1000)) {
      return null;
    }

    // Valid lap completion.
    final crossing = LapCrossing(
      timestamp: now,
      lapTime: elapsed,
      lapNumber: _lapCount,
    );

    _lapCount++;
    _lapStartTime = now;

    return crossing;
  }

  /// Determine whether two 2D line segments intersect.
  ///
  /// Segment 1: (ax1,ay1)→(ax2,ay2)  — the car's path
  /// Segment 2: (bx1,by1)→(bx2,by2)  — the finish line
  ///
  /// Uses the standard parametric intersection test.
  static bool _segmentsIntersect(
    double ax1,
    double ay1,
    double ax2,
    double ay2,
    double bx1,
    double by1,
    double bx2,
    double by2,
  ) {
    final dx1 = ax2 - ax1;
    final dy1 = ay2 - ay1;
    final dx2 = bx2 - bx1;
    final dy2 = by2 - by1;

    final denom = dx1 * dy2 - dy1 * dx2;

    // Parallel lines (or coincident) — treat as no crossing.
    if (denom.abs() < 1e-12) return false;

    final t = ((bx1 - ax1) * dy2 - (by1 - ay1) * dx2) / denom;
    final u = ((bx1 - ax1) * dy1 - (by1 - ay1) * dx1) / denom;

    // Both parameters must be in [0, 1] for the segments to intersect.
    return t >= 0 && t <= 1 && u >= 0 && u <= 1;
  }
}

// ── Riverpod provider ──────────────────────────────────────────────────

final lapDetectorProvider = Provider<LapDetector>((ref) {
  return LapDetector();
});
