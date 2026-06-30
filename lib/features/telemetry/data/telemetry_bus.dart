import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/features/telemetry/domain/telemetry_state.dart';

// =============================================================================
// TelemetryBus — central state hub
// =============================================================================

/// Central hub that receives normalised telemetry sub-messages from adapters
/// and merges them into a single [TelemetryState].
///
/// Each `update*` method writes exactly one data slot and refreshes the
/// corresponding timestamp + active-sources list.
class TelemetryBus extends StateNotifier<TelemetryState> {
  TelemetryBus() : super(TelemetryState.empty());

  // ---------------------------------------------------------------------------
  // Per-slot updates
  // ---------------------------------------------------------------------------

  /// Replace the GPS data slot.
  void updateGps(GpsData data, SourceType source) {
    state = state.copyWith(
      gps: data,
      gpsUpdatedAt: DateTime.now(),
      activeSources: _ensureSource(source),
    );
  }

  /// Replace the motion data slot.
  void updateMotion(MotionData data, SourceType source) {
    state = state.copyWith(
      motion: data,
      motionUpdatedAt: DateTime.now(),
      activeSources: _ensureSource(source),
    );
  }

  /// Replace the engine data slot.
  void updateEngine(EngineData data, SourceType source) {
    state = state.copyWith(
      engine: data,
      engineUpdatedAt: DateTime.now(),
      activeSources: _ensureSource(source),
    );
  }

  /// Replace the fuel data slot.
  void updateFuel(FuelData data, SourceType source) {
    state = state.copyWith(
      fuel: data,
      fuelUpdatedAt: DateTime.now(),
      activeSources: _ensureSource(source),
    );
  }

  // ---------------------------------------------------------------------------
  // Full-frame update
  // ---------------------------------------------------------------------------

  /// Apply all non-null sub-messages from a complete [TelemetryFrame].
  ///
  /// This is the primary ingestion path used by adapters that produce a
  /// full frame in one shot (e.g., RaceBox).
  void updateFrame(TelemetryFrame frame) {
    final now = DateTime.now();
    final source = frame.sourceType;
    final sources = _ensureSource(source);

    state = state.copyWith(
      gps: frame.hasGps() ? frame.gps : null,
      motion: frame.hasMotion() ? frame.motion : null,
      engine: frame.hasEngine() ? frame.engine : null,
      fuel: frame.hasFuel() ? frame.fuel : null,
      gpsUpdatedAt: frame.hasGps() ? now : null,
      motionUpdatedAt: frame.hasMotion() ? now : null,
      engineUpdatedAt: frame.hasEngine() ? now : null,
      fuelUpdatedAt: frame.hasFuel() ? now : null,
      activeSources: sources,
    );
  }

  // ---------------------------------------------------------------------------
  // Source management
  // ---------------------------------------------------------------------------

  /// Remove a [source] from the active list (e.g., on device disconnect).
  void removeSource(SourceType source) {
    final updated = List<SourceType>.from(state.activeSources)..remove(source);
    state = state.copyWith(activeSources: updated);
  }

  /// Reset all state back to empty.
  void reset() {
    state = TelemetryState.empty();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Return the current active-sources list with [source] added if not present.
  List<SourceType> _ensureSource(SourceType source) {
    if (state.activeSources.contains(source)) {
      return state.activeSources;
    }
    return [...state.activeSources, source];
  }
}

// =============================================================================
// Riverpod providers
// =============================================================================

/// The single [TelemetryBus] instance used across the app.
final telemetryBusProvider =
    StateNotifierProvider<TelemetryBus, TelemetryState>(
      (ref) => TelemetryBus(),
    );

/// Watches just the GPS data slot.
final currentGpsProvider = Provider<GpsData?>((ref) {
  return ref.watch(telemetryBusProvider).gps;
});

/// Watches just the current speed in km/h (defaults to 0).
final currentSpeedProvider = Provider<double>((ref) {
  return ref.watch(telemetryBusProvider).speedKmh;
});

/// Watches just the motion data slot.
final currentMotionProvider = Provider<MotionData?>((ref) {
  return ref.watch(telemetryBusProvider).motion;
});

/// Watches just the engine data slot.
final currentEngineProvider = Provider<EngineData?>((ref) {
  return ref.watch(telemetryBusProvider).engine;
});
