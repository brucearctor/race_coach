import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/coach_mode_bridge.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';
import 'package:race_coach/features/coaching/domain/audio_mode.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';
import 'package:race_coach/features/telemetry/domain/telemetry_state.dart';

// =============================================================================
// Coaching Bridge Provider — activates Rust analysis pipeline on telemetry
// =============================================================================

/// Bridge provider that connects the telemetry stream to the Rust coaching
/// engine when AudioMode.coach is active.
///
/// Watch this provider from the dashboard to keep it alive. When active, it:
/// 1. Listens to telemetry updates from TelemetryBus
/// 2. Converts them to RaceBoxData for the CoachModeBridge
/// 3. Routes through Rust process_frame() at 25 Hz
/// 4. Updates coaching output providers (deltaT, braking, etc.)
///
/// When AudioMode != coach, this provider is a no-op.
final coachingBridgeActivationProvider = Provider<void>((ref) {
  final audioMode = ref.watch(audioModeProvider);
  if (audioMode != AudioMode.coach) return;

  // Ensure the Rust session is managed.
  ref.watch(rustSessionManagerProvider);

  // Listen to telemetry updates and forward to the Rust engine.
  ref.listen<TelemetryState>(
    telemetryBusProvider,
    (previous, next) {
      // Only process if we have GPS data.
      if (next.gps == null) return;

      final gps = next.gps!;
      final motion = next.motion;

      final data = RaceBoxData(
        timestamp: DateTime.now(),
        latitude: gps.latitude,
        longitude: gps.longitude,
        speedKmh: gps.speedKmh,
        headingDegrees: gps.headingDegrees,
        altitudeMeters: gps.altitudeMeters,
        gForceX: motion?.gForceLateral ?? 0,
        gForceY: motion?.gForceLongitudinal ?? 0,
        gForceZ: motion?.gForceVertical ?? 0,
        satellites: gps.satellites.toInt(),
        hdop: gps.hdop,
      );

      ref.read(coachModeBridgeProvider).processTelemetry(data);
    },
  );
});
