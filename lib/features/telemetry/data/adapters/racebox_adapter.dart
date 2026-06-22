import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as proto_ts;

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';
import 'package:race_coach/features/racebox/data/racebox_providers.dart';
import 'package:race_coach/features/racebox/data/racebox_service.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';

// =============================================================================
// RaceBoxAdapter — RaceBoxData → TelemetryFrame
// =============================================================================

/// Adapter that bridges [RaceBoxData] (hand-written BLE model) into the
/// normalised proto-based [TelemetryFrame] world.
class RaceBoxAdapter {
  const RaceBoxAdapter._();

  // ---------------------------------------------------------------------------
  // Conversion
  // ---------------------------------------------------------------------------

  /// Convert a single [RaceBoxData] sample into a [TelemetryFrame].
  ///
  /// RaceBox provides GPS + accelerometer data, so we fill the `gps` and
  /// `motion` sub-messages.  Engine / fuel are left unset.
  static TelemetryFrame fromRaceBoxData(RaceBoxData data) {
    final gps = GpsData()
      ..latitude = data.latitude
      ..longitude = data.longitude
      ..speedKmh = data.speedKmh
      ..headingDegrees = data.headingDegrees
      ..altitudeMeters = data.altitudeMeters
      ..satellites = data.satellites
      ..hdop = data.hdop;

    final motion = MotionData()
      ..gForceLateral = data.gForceX
      ..gForceLongitudinal = data.gForceY
      ..gForceVertical = data.gForceZ;

    final deviceTs = _timestampFromDateTime(data.timestamp);
    final arrivalTs = _timestampFromDateTime(DateTime.now());

    return TelemetryFrame()
      ..gps = gps
      ..motion = motion
      ..sourceType = SourceType.SOURCE_TYPE_RACEBOX_MINI
      ..deviceTimestamp = deviceTs
      ..arrivalTimestamp = arrivalTs
      ..rawPayload = Uint8List(0);
  }

  // ---------------------------------------------------------------------------
  // Timestamp helper
  // ---------------------------------------------------------------------------

  static proto_ts.Timestamp _timestampFromDateTime(DateTime dt) {
    return proto_ts.Timestamp()
      ..seconds = Int64(dt.millisecondsSinceEpoch ~/ 1000)
      ..nanos = (dt.millisecondsSinceEpoch % 1000) * 1000000;
  }
}

// =============================================================================
// Riverpod bridge provider
// =============================================================================

/// A provider that watches [raceBoxDataStreamProvider] and automatically pumps
/// each new sample through [RaceBoxAdapter] into the [TelemetryBus].
///
/// Simply reading (or watching) this provider from a top-level widget is
/// enough to activate the bridge.  The returned value is the most recent
/// [TelemetryFrame] that was pushed, or `null` if no data has arrived.
final raceBoxTelemetryBridgeProvider = Provider<TelemetryFrame?>((ref) {
  final raceBoxAsync = ref.watch(raceBoxDataStreamProvider);

  return raceBoxAsync.whenOrNull<TelemetryFrame?>(
    data: (raceBoxData) {
      // Don't push the initial empty sentinel through the bus.
      if (raceBoxData.timestamp.millisecondsSinceEpoch == 0) {
        return null;
      }

      // Also sync the state provider so other consumers stay in sync.
      Future.microtask(() {
        ref.read(raceBoxDataProvider.notifier).state = raceBoxData;
      });

      final frame = RaceBoxAdapter.fromRaceBoxData(raceBoxData);

      // Schedule the bus update for after the current build phase to avoid
      // modifying provider state during a build.
      Future.microtask(() {
        ref.read(telemetryBusProvider.notifier).updateFrame(frame);
      });

      return frame;
    },
  );
});
