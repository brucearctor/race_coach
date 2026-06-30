import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'lap_detector.dart';
import 'package:race_coach/features/track/data/track_service.dart';
import 'package:race_coach/features/racebox/data/racebox_service.dart';
import 'package:race_coach/features/live/presentation/widgets/lap_timer_widget.dart';

// =============================================================================
// Lap Detection Bridge — wires GPS stream → LapDetector → LapTimer
// =============================================================================

/// Activating (watching) this provider connects the GPS data stream to the
/// [LapDetector] and triggers [LapTimerNotifier.completeLap] whenever a
/// finish-line crossing is detected.
///
/// The provider is side-effect-only (`Provider<void>`). Watch it from a
/// connected-state widget (e.g., `LiveDashboardScreen`) to keep the pipeline
/// alive while the dashboard is mounted.
final lapDetectionBridgeProvider = Provider<void>((ref) {
  final lapDetector = ref.watch(lapDetectorProvider);

  // ── 1. Configure the finish line from the selected track config ────────
  final config = ref.watch(selectedConfigProvider);

  if (config != null && config.hasFinishLineA() && config.hasFinishLineB()) {
    final a = config.finishLineA;
    final b = config.finishLineB;
    lapDetector.setFinishLine(
      LatLng(a.latitude, a.longitude),
      LatLng(b.latitude, b.longitude),
    );
    debugPrint(
      '[LapBridge] Finish line set: '
      '(${a.latitude}, ${a.longitude}) → (${b.latitude}, ${b.longitude})',
    );
  } else {
    // No valid finish line — reset so we don't detect stale crossings.
    lapDetector.reset();
    debugPrint(
      '[LapBridge] No finish line configured — lap detection inactive',
    );
    return;
  }

  // ── 2. Track previous GPS position across stream events ────────────────
  LatLng? previousPosition;

  // ── 3. Listen to the RaceBox GPS stream ────────────────────────────────
  ref.listen<AsyncValue<dynamic>>(raceBoxDataStreamProvider, (previous, next) {
    final data = next.valueOrNull;
    if (data == null) return;

    final currentPosition = LatLng(data.latitude, data.longitude);

    // Skip (0, 0) or clearly invalid positions.
    if (data.latitude == 0.0 && data.longitude == 0.0) return;

    if (previousPosition != null) {
      final crossing = lapDetector.checkCrossing(
        previousPosition!,
        currentPosition,
      );

      if (crossing != null) {
        debugPrint('[LapBridge] 🏁 Lap crossing detected: $crossing');
        ref.read(lapTimerProvider.notifier).completeLap();
      } else if (lapDetector.currentLap == 1 &&
          !ref.read(lapTimerProvider).isRunning) {
        // The detector just saw its first crossing (currentLap flipped
        // from 0 → 1) but returned null because there's no completed
        // lap yet — start the timer so the first lap is timed.
        //
        // NOTE: We detect this by checking that the detector advanced to
        // lap 1 while the timer isn't running yet.  This is a one-shot
        // condition; subsequent builds won't re-trigger because the
        // timer will already be running.
      }
    }

    // Check if the detector just started its first lap (previousPosition
    // existed, we called checkCrossing, detector moved to lap 1, and
    // timer is not yet running).
    if (lapDetector.currentLap >= 1 && !ref.read(lapTimerProvider).isRunning) {
      debugPrint('[LapBridge] ⏱️ Starting lap timer (first crossing)');
      ref.read(lapTimerProvider.notifier).start();
    }

    previousPosition = currentPosition;
  });
});
