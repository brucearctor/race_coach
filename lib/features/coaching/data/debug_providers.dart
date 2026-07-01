import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';
import 'package:race_coach/src/rust/api/coaching_api.dart' as rust;

// =============================================================================
// Developer Mode — guarded by a hidden toggle in settings
// =============================================================================

/// Whether developer / debug mode is active.
///
/// Controlled from Settings → tap the version string 7 times.
final developerModeProvider = StateProvider<bool>((ref) => false);

// =============================================================================
// GPS Quality — derived from the telemetry bus
// =============================================================================

/// Lightweight snapshot of GPS signal quality for the debug HUD.
class GpsQuality {
  const GpsQuality({
    this.satellites = 0,
    this.hdop = 99.0,
    this.speedKmh = 0.0,
  });

  final int satellites;
  final double hdop;
  final double speedKmh;

  /// Human-readable GPS quality label.
  String get label {
    if (satellites == 0) return 'NO FIX';
    if (satellites >= 12 && hdop < 1.5) return 'RTK';
    if (satellites >= 8 && hdop < 2.0) return 'EXCELLENT';
    if (satellites >= 6 && hdop < 3.0) return 'GOOD';
    if (satellites >= 4) return 'FAIR';
    return 'POOR';
  }
}

/// Current GPS quality derived from the telemetry bus.
final gpsQualityProvider = Provider<GpsQuality>((ref) {
  final telemetry = ref.watch(telemetryBusProvider);
  final gps = telemetry.gps;
  if (gps == null) return const GpsQuality();
  return GpsQuality(
    satellites: gps.satellites,
    hdop: gps.hdop,
    speedKmh: gps.speedKmh,
  );
});

// =============================================================================
// Debug Engine State — parsed from the Rust JSON endpoint
// =============================================================================

/// Snapshot of the Rust CueEngine's internal state.
class DebugEngineState {
  const DebugEngineState({
    this.queueDepth = 0,
    this.maxQueueDepth = 8,
    this.cuesEmittedLap = 0,
    this.cuesFilteredLap = 0,
    this.cuesEmittedSession = 0,
    this.cuesFilteredSession = 0,
    this.activeCooldowns = const [],
  });

  final int queueDepth;
  final int maxQueueDepth;
  final int cuesEmittedLap;
  final int cuesFilteredLap;
  final int cuesEmittedSession;
  final int cuesFilteredSession;
  final List<CooldownEntry> activeCooldowns;

  factory DebugEngineState.fromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return DebugEngineState(
        queueDepth: (map['queueDepth'] as num?)?.toInt() ?? 0,
        maxQueueDepth: (map['maxQueueDepth'] as num?)?.toInt() ?? 8,
        cuesEmittedLap: (map['cuesEmittedLap'] as num?)?.toInt() ?? 0,
        cuesFilteredLap: (map['cuesFilteredLap'] as num?)?.toInt() ?? 0,
        cuesEmittedSession: (map['cuesEmittedSession'] as num?)?.toInt() ?? 0,
        cuesFilteredSession: (map['cuesFilteredSession'] as num?)?.toInt() ?? 0,
        activeCooldowns:
            (map['activeCooldowns'] as List<dynamic>?)
                ?.map((e) => CooldownEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (_) {
      return const DebugEngineState();
    }
  }
}

/// A single active cooldown entry.
class CooldownEntry {
  const CooldownEntry({required this.cueType, required this.framesRemaining});

  final String cueType;
  final int framesRemaining;

  factory CooldownEntry.fromJson(Map<String, dynamic> map) {
    return CooldownEntry(
      cueType: map['cueType'] as String? ?? '',
      framesRemaining: (map['framesRemaining'] as num?)?.toInt() ?? 0,
    );
  }
}

/// The latest debug engine state, polled when dev mode is active.
final debugEngineStateProvider = StateProvider<DebugEngineState>(
  (ref) => const DebugEngineState(),
);

/// Call this from the frame loop (piggybacked on processFrame) when
/// developer mode is enabled.
Future<void> pollDebugState(Ref ref) async {
  if (!ref.read(developerModeProvider)) return;
  if (!ref.read(rustSessionActiveProvider)) return;

  try {
    final json = await rust.getDebugStateJson();
    ref.read(debugEngineStateProvider.notifier).state =
        DebugEngineState.fromJson(json);
  } catch (_) {
    // Debug polling should never crash the hot path.
  }
}
