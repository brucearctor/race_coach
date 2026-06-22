import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/audio_coach.dart';
import 'package:race_coach/features/coaching/domain/audio_mode.dart';
import 'package:race_coach/features/coaching/domain/coaching_cue.dart';
import 'package:race_coach/features/live/presentation/widgets/lap_timer_widget.dart';

// =============================================================================
// Lap Time Announcer — speaks lap times at finish line crossings
// =============================================================================

/// Watches [lapTimerProvider] and announces lap times via TTS when a
/// lap is completed.
///
/// Active for ALL [AudioMode] values except [AudioMode.off].
/// Watch this provider from the live dashboard to keep the pipeline alive.
final lapTimeAnnouncerProvider = Provider<void>((ref) {
  final mode = ref.watch(audioModeProvider);
  if (mode == AudioMode.off) return;

  final audioCoach = ref.read(audioCoachProvider);

  // Track previous lap count to detect new completions.
  int previousLapCount = ref.read(lapTimerProvider).lapCount;

  // Store the last completed lap time so we can announce it.
  // When completeLap() fires, the timer resets currentLapTime to zero
  // and updates bestLapTime — so we need to capture the previous
  // currentLapTime before the reset.
  Duration? previousLapTime;

  ref.listen<LapTimerState>(
    lapTimerProvider,
    (previous, next) {
      // Capture the current lap time before it resets to zero.
      if (previous != null && next.currentLapTime == Duration.zero &&
          previous.currentLapTime > const Duration(seconds: 10)) {
        previousLapTime = previous.currentLapTime;
      }

      // Detect lap completion: lapCount increased.
      if (next.lapCount > previousLapCount) {
        previousLapCount = next.lapCount;

        // The completed lap time is the previousLapTime we captured.
        final lapTime = previousLapTime;
        if (lapTime == null) return;

        final message = _buildMessage(
          lapTime: lapTime,
          bestLapTime: next.bestLapTime,
        );

        debugPrint('[LapTimeAnnouncer] 🏁 Lap ${next.lapCount}: $message');

        audioCoach.speak(CoachingCue(
          type: CoachingCueType.lapTime,
          message: message,
          priority: CuePriority.high,
          timestamp: DateTime.now(),
        ));

        previousLapTime = null;
      }
    },
  );
});

// ── Message building ──────────────────────────────────────────────────

/// Build the spoken message for a completed lap.
String _buildMessage({
  required Duration lapTime,
  required Duration? bestLapTime,
}) {
  final timeStr = _formatLapTimeForSpeech(lapTime);

  // This lap IS the new best.
  if (bestLapTime != null && lapTime <= bestLapTime) {
    return 'New best! $timeStr';
  }

  // There is a best and this lap is slower.
  if (bestLapTime != null) {
    final delta = lapTime - bestLapTime;
    final deltaSeconds = delta.inMilliseconds / 1000.0;

    if (deltaSeconds < 1.0) {
      final deltaTenths = (delta.inMilliseconds / 100).round();
      return '$timeStr, $deltaTenths tenths slower';
    }

    final deltaWhole = deltaSeconds.round();
    return '$timeStr, $deltaWhole ${deltaWhole == 1 ? 'second' : 'seconds'} slower';
  }

  // First lap — no best yet.
  return timeStr;
}

/// Format a [Duration] for natural TTS speech.
///
/// Examples:
/// - 1:42.300 → "1 42 3"
/// - 0:58.700 → "58 point 7"
String _formatLapTimeForSpeech(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  final tenths = (d.inMilliseconds % 1000) ~/ 100;

  if (minutes > 0) {
    return '$minutes ${seconds.toString().padLeft(2, '0')} $tenths';
  }
  return '$seconds point $tenths';
}
