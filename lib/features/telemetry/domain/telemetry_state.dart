import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';

/// Mutable current-state snapshot aggregating the latest telemetry data
/// across all connected sources.
///
/// Each data slot (GPS, motion, engine, fuel) is nullable — `null` means
/// no data has arrived yet for that category.  The corresponding
/// `*UpdatedAt` field records when the slot was last written.
class TelemetryState {
  final GpsData? gps;
  final MotionData? motion;
  final EngineData? engine;
  final FuelData? fuel;

  final DateTime? gpsUpdatedAt;
  final DateTime? motionUpdatedAt;
  final DateTime? engineUpdatedAt;
  final DateTime? fuelUpdatedAt;

  /// Which source types are currently feeding the bus.
  final List<SourceType> activeSources;

  const TelemetryState({
    this.gps,
    this.motion,
    this.engine,
    this.fuel,
    this.gpsUpdatedAt,
    this.motionUpdatedAt,
    this.engineUpdatedAt,
    this.fuelUpdatedAt,
    this.activeSources = const [],
  });

  /// A fresh, empty state before any data has arrived.
  factory TelemetryState.empty() => const TelemetryState();

  // ---------------------------------------------------------------------------
  // Presence helpers
  // ---------------------------------------------------------------------------

  bool get hasGps => gps != null;
  bool get hasMotion => motion != null;
  bool get hasEngine => engine != null;
  bool get hasFuel => fuel != null;

  // ---------------------------------------------------------------------------
  // Convenience accessors
  // ---------------------------------------------------------------------------

  /// Current speed in km/h from the GPS slot (0 if absent).
  double get speedKmh => gps?.speedKmh ?? 0;

  /// Current speed in mph from the GPS slot (0 if absent).
  double get speedMph => speedKmh * 0.621371;

  /// Lateral (side-to-side) G-force from the motion slot (0 if absent).
  double get lateralG => motion?.gForceLateral ?? 0;

  /// Longitudinal (fore-aft) G-force from the motion slot (0 if absent).
  double get longitudinalG => motion?.gForceLongitudinal ?? 0;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  TelemetryState copyWith({
    GpsData? gps,
    MotionData? motion,
    EngineData? engine,
    FuelData? fuel,
    DateTime? gpsUpdatedAt,
    DateTime? motionUpdatedAt,
    DateTime? engineUpdatedAt,
    DateTime? fuelUpdatedAt,
    List<SourceType>? activeSources,
    // Sentinel flags — allow explicitly setting a slot to null.
    bool clearGps = false,
    bool clearMotion = false,
    bool clearEngine = false,
    bool clearFuel = false,
  }) {
    return TelemetryState(
      gps: clearGps ? null : (gps ?? this.gps),
      motion: clearMotion ? null : (motion ?? this.motion),
      engine: clearEngine ? null : (engine ?? this.engine),
      fuel: clearFuel ? null : (fuel ?? this.fuel),
      gpsUpdatedAt: gpsUpdatedAt ?? this.gpsUpdatedAt,
      motionUpdatedAt: motionUpdatedAt ?? this.motionUpdatedAt,
      engineUpdatedAt: engineUpdatedAt ?? this.engineUpdatedAt,
      fuelUpdatedAt: fuelUpdatedAt ?? this.fuelUpdatedAt,
      activeSources: activeSources ?? this.activeSources,
    );
  }

  @override
  String toString() =>
      'TelemetryState(gps: ${hasGps ? "✓" : "✗"}, motion: ${hasMotion ? "✓" : "✗"}, '
      'engine: ${hasEngine ? "✓" : "✗"}, fuel: ${hasFuel ? "✓" : "✗"}, '
      'sources: $activeSources)';
}
