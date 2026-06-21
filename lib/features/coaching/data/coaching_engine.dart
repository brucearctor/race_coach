import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/audio_coach.dart';
import 'package:race_coach/features/coaching/domain/coaching_cue.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';

/// Real-time coaching engine that analyses telemetry data and generates
/// spoken coaching cues via [AudioCoach].
///
/// V1 capabilities:
/// - Speed announcements at configurable intervals
/// - Lateral g-force warnings when exceeding threshold
/// - Lap completion announcements
class CoachingEngine {
  CoachingEngine({required this.audioCoach});

  final AudioCoach audioCoach;

  // ── Configuration ──────────────────────────────────────────────────

  /// Whether speed announcements are enabled.
  bool announceSpeed = true;

  /// Interval between speed announcements.
  Duration speedAnnounceInterval = const Duration(seconds: 15);

  /// Lateral g-force threshold that triggers a warning.
  double lateralGWarningThreshold = 1.2;

  /// Whether to announce lap times on completion.
  bool announceLapTimes = true;

  /// Whether to use mph (true) or km/h (false).
  bool useMph = true;

  // ── Internal state ─────────────────────────────────────────────────

  DateTime _lastSpeedAnnounce = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastGWarning = DateTime.fromMillisecondsSinceEpoch(0);

  /// Minimum interval between g-force warnings.
  static const Duration _gWarningCooldown = Duration(seconds: 10);

  // ── Public API ─────────────────────────────────────────────────────

  /// Called on each new GPS / telemetry update.
  void processTelemetry(RaceBoxData data) {
    _checkSpeedAnnouncement(data);
    _checkGForceWarning(data);
  }

  /// Called when a lap is completed.
  void onLapCompleted(Duration lapTime, Duration? bestLap, int lapNumber) {
    if (!announceLapTimes) return;

    final lapTimeStr = _formatDuration(lapTime);
    String message = 'Lap $lapNumber complete. $lapTimeStr.';

    if (bestLap != null) {
      final delta = lapTime - bestLap;
      if (delta.isNegative) {
        message += ' New best lap!';
      } else if (delta.inMilliseconds > 0) {
        final deltaStr = _formatDelta(delta);
        message += ' Plus $deltaStr.';
      }
    }

    audioCoach.speak(CoachingCue(
      type: CoachingCueType.sectorTime,
      message: message,
      priority: CuePriority.high,
      timestamp: DateTime.now(),
    ));
  }

  // ── Private helpers ────────────────────────────────────────────────

  void _checkSpeedAnnouncement(RaceBoxData data) {
    if (!announceSpeed) return;

    final now = DateTime.now();
    if (now.difference(_lastSpeedAnnounce) < speedAnnounceInterval) return;

    final speed = useMph ? data.speedMph : data.speedKmh;
    final unit = useMph ? 'miles per hour' : 'kilometers per hour';
    final rounded = speed.round();

    if (rounded < 5) return; // Don't announce when stationary.

    _lastSpeedAnnounce = now;
    audioCoach.speak(CoachingCue(
      type: CoachingCueType.speed,
      message: '$rounded $unit.',
      priority: CuePriority.low,
      timestamp: now,
    ));
  }

  void _checkGForceWarning(RaceBoxData data) {
    final lateralMag = data.lateralG.abs();
    if (lateralMag < lateralGWarningThreshold) return;

    final now = DateTime.now();
    if (now.difference(_lastGWarning) < _gWarningCooldown) return;

    _lastGWarning = now;

    final direction = data.lateralG > 0 ? 'right' : 'left';
    final gStr = lateralMag.toStringAsFixed(1);

    audioCoach.speak(CoachingCue(
      type: CoachingCueType.general,
      message: 'High lateral g. $gStr g to the $direction.',
      priority: CuePriority.medium,
      timestamp: now,
    ));
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    final millis = d.inMilliseconds % 1000;
    final tenths = (millis / 100).floor();

    if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? 's' : ''} $seconds point $tenths';
    }
    return '$seconds point $tenths seconds';
  }

  String _formatDelta(Duration delta) {
    final seconds = delta.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(1)} seconds';
  }
}

// ── Riverpod provider ──────────────────────────────────────────────────

final coachingEngineProvider = Provider<CoachingEngine>((ref) {
  final audioCoach = ref.watch(audioCoachProvider);
  return CoachingEngine(audioCoach: audioCoach);
});
