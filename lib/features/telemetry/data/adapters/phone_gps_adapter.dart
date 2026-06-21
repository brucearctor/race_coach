import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as proto_ts;

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';

// =============================================================================
// PhoneGpsAdapter — Geolocator Position → TelemetryFrame
// =============================================================================

/// Adapter that bridges the phone's built-in GPS (via [Geolocator]) into
/// normalised proto-based [TelemetryFrame]s.
class PhoneGpsAdapter {
  const PhoneGpsAdapter._();

  // ---------------------------------------------------------------------------
  // Stream factory
  // ---------------------------------------------------------------------------

  /// Start listening to phone GPS and yield [TelemetryFrame]s.
  ///
  /// [accuracy] defaults to [LocationAccuracy.best] which is what you want
  /// on a race track (high refresh rate, GPS + GLONASS + Galileo).
  ///
  /// [distanceFilter] defaults to 0 so we get updates as fast as the OS
  /// allows (typically ~1 Hz on iOS, 1–5 Hz on Android).
  static Stream<TelemetryFrame> startListening({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 0,
  }) {
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: settings)
        .map(_positionToFrame);
  }

  // ---------------------------------------------------------------------------
  // Conversion
  // ---------------------------------------------------------------------------

  /// Convert a single [Position] into a [TelemetryFrame].
  ///
  /// Phone GPS provides position and (optionally) speed / heading but no
  /// accelerometer data, so we only fill the `gps` sub-message.
  static TelemetryFrame _positionToFrame(Position position) {
    final gps = GpsData()
      ..latitude = position.latitude
      ..longitude = position.longitude
      ..altitudeMeters = position.altitude;

    // Speed from Geolocator is m/s; convert to km/h.
    if (position.speed >= 0) {
      gps.speedKmh = position.speed * 3.6;
    }

    if (position.heading >= 0) {
      gps.headingDegrees = position.heading;
    }

    // Geolocator doesn't expose satellite count or HDOP directly, but
    // `accuracy` (in meters) serves as a rough quality indicator.
    // We leave satellites/hdop unset — consumers should check `hasHdop()`.

    final arrivalTs = _timestampFromDateTime(DateTime.now());

    return TelemetryFrame()
      ..gps = gps
      ..sourceType = SourceType.SOURCE_TYPE_PHONE_GPS
      ..arrivalTimestamp = arrivalTs;
    // Note: no deviceTimestamp — phone GPS doesn't expose a separate device
    // clock that's meaningfully different from arrival time.
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
// Riverpod providers
// =============================================================================

/// Whether the phone GPS adapter should be active.
///
/// Toggle this to start/stop the phone GPS stream without disposing the
/// entire provider tree.
final phoneGpsEnabledProvider = StateProvider<bool>((ref) => false);

/// Streams [TelemetryFrame]s from the phone GPS and automatically pushes
/// them into the [TelemetryBus].
///
/// Only active when [phoneGpsEnabledProvider] is `true`.
final phoneGpsStreamProvider = StreamProvider<TelemetryFrame>((ref) {
  final enabled = ref.watch(phoneGpsEnabledProvider);
  if (!enabled) {
    return const Stream.empty();
  }

  final controller = StreamController<TelemetryFrame>();

  final subscription = PhoneGpsAdapter.startListening().listen(
    (frame) {
      ref.read(telemetryBusProvider.notifier).updateFrame(frame);
      controller.add(frame);
    },
    onError: controller.addError,
  );

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});
