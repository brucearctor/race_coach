import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/audio_coach.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';
import 'package:race_coach/features/coaching/domain/audio_mode.dart';
import 'package:race_coach/features/coaching/domain/coaching_cue.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';
import 'package:race_coach/src/rust/api/coaching_api.dart' as rust;
import 'package:race_coach/src/rust/types.dart' as rust;

// =============================================================================
// CoachModeBridge — connects telemetry stream to Rust analysis engine
// =============================================================================

/// Bridge that takes incoming [RaceBoxData] frames and routes them through
/// the Rust analysis engine when AudioMode.coach is active.
///
/// This is the hot path — called 25x/sec. It:
/// 1. Converts [RaceBoxData] → Rust [TelemetryInput]
/// 2. Calls Rust `process_frame()` via FFI
/// 3. Updates [rustFrameOutputProvider] with the result
/// 4. Routes coaching cues to [AudioCoach] for TTS
class CoachModeBridge {
  CoachModeBridge({
    required this.ref,
    required this.audioCoach,
  });

  final Ref ref;
  final AudioCoach audioCoach;

  /// Process a single telemetry frame through the Rust engine.
  ///
  /// Returns immediately if coach mode is not active or no Rust session exists.
  Future<void> processTelemetry(RaceBoxData data) async {
    // Skip if not in coach mode or no active session.
    if (ref.read(audioModeProvider) != AudioMode.coach) return;
    if (!ref.read(rustSessionActiveProvider)) return;

    // Convert Dart → Rust input
    final input = _toRustInput(data);

    // Call Rust — this crosses the FFI boundary
    final output = await rust.processFrame(input: input);

    // Update the output provider (triggers UI rebuilds)
    ref.read(rustFrameOutputProvider.notifier).state = output;

    // Route coaching cues to audio
    for (final cue in output.coachingCues) {
      audioCoach.speak(_toDartCue(cue));
    }
  }

  /// Called when a new lap starts (finish line crossing detected).
  Future<void> onLapReset() async {
    if (!ref.read(rustSessionActiveProvider)) return;
    await rust.resetLap();
  }

  // ─── Type conversions ───────────────────────────────────────────────

  static rust.TelemetryInput _toRustInput(RaceBoxData data) {
    return rust.TelemetryInput(
      timestampMs: BigInt.from(data.timestamp.millisecondsSinceEpoch),
      latitude: data.latitude,
      longitude: data.longitude,
      speedKmh: data.speedKmh,
      headingDeg: data.headingDegrees,
      altitudeM: data.altitudeMeters,
      gLateral: data.gForceX,
      gLongitudinal: data.gForceY,
      gVertical: data.gForceZ,
      satellites: data.satellites,
      hdop: data.hdop,
    );
  }

  static CoachingCue _toDartCue(rust.CoachingCue rustCue) {
    return CoachingCue(
      type: _mapCueType(rustCue.cueType),
      message: rustCue.message,
      priority: _mapPriority(rustCue.priority),
      timestamp: DateTime.now(),
    );
  }

  static CoachingCueType _mapCueType(rust.CueType t) => switch (t) {
    rust.CueType.braking => CoachingCueType.braking,
    rust.CueType.throttle => CoachingCueType.throttle,
    rust.CueType.line => CoachingCueType.line,
    rust.CueType.speed => CoachingCueType.speed,
    rust.CueType.sectorTime => CoachingCueType.sectorTime,
    rust.CueType.lapTime => CoachingCueType.lapTime,
    rust.CueType.gForce => CoachingCueType.general,
    rust.CueType.general => CoachingCueType.general,
    rust.CueType.coasting => CoachingCueType.coasting,
    rust.CueType.trailBraking => CoachingCueType.trailBraking,
    rust.CueType.gripUtilization => CoachingCueType.general,
    rust.CueType.mlBraking => CoachingCueType.braking,
    rust.CueType.mlThrottle => CoachingCueType.throttle,
  };

  static CuePriority _mapPriority(rust.CuePriority p) => switch (p) {
    rust.CuePriority.low => CuePriority.low,
    rust.CuePriority.medium => CuePriority.medium,
    rust.CuePriority.high => CuePriority.high,
    rust.CuePriority.critical => CuePriority.critical,
  };
}

// =============================================================================
// Riverpod provider
// =============================================================================

/// The CoachModeBridge singleton — manages telemetry → Rust → audio flow.
final coachModeBridgeProvider = Provider<CoachModeBridge>((ref) {
  final audioCoach = ref.watch(audioCoachProvider);
  return CoachModeBridge(ref: ref, audioCoach: audioCoach);
});
