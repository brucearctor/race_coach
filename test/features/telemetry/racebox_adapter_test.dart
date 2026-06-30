import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/racebox/domain/racebox_data.dart';
import 'package:race_coach/features/telemetry/data/adapters/racebox_adapter.dart';
import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';

void main() {
  /// A reusable test RaceBoxData sample with known values.
  RaceBoxData makeTestData({
    double latitude = 37.53753,
    double longitude = -122.32508,
    double speedKmh = 105.5,
    double headingDegrees = 180.0,
    double altitudeMeters = 52.3,
    int satellites = 14,
    double hdop = 0.8,
    double gForceX = 0.45,
    double gForceY = -0.32,
    double gForceZ = 0.98,
    DateTime? timestamp,
  }) {
    return RaceBoxData(
      timestamp: timestamp ?? DateTime.utc(2025, 6, 15, 10, 30, 0),
      latitude: latitude,
      longitude: longitude,
      speedKmh: speedKmh,
      headingDegrees: headingDegrees,
      altitudeMeters: altitudeMeters,
      gForceX: gForceX,
      gForceY: gForceY,
      gForceZ: gForceZ,
      satellites: satellites,
      hdop: hdop,
    );
  }

  // ===========================================================================
  // GPS data mapping
  // ===========================================================================

  group('RaceBoxAdapter GPS mapping', () {
    test('maps latitude and longitude correctly', () {
      final data = makeTestData(latitude: 39.538, longitude: -122.328);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.hasGps(), isTrue);
      expect(frame.gps.latitude, equals(39.538));
      expect(frame.gps.longitude, equals(-122.328));
    });

    test('maps speed in km/h', () {
      final data = makeTestData(speedKmh: 145.7);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      // Proto float has limited precision, so use closeTo.
      expect(frame.gps.speedKmh, closeTo(145.7, 0.1));
    });

    test('maps heading in degrees', () {
      final data = makeTestData(headingDegrees: 270.5);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.gps.headingDegrees, closeTo(270.5, 0.1));
    });

    test('maps altitude in meters', () {
      final data = makeTestData(altitudeMeters: 123.456);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.gps.altitudeMeters, closeTo(123.456, 0.1));
    });

    test('maps satellites count', () {
      final data = makeTestData(satellites: 18);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.gps.satellites, equals(18));
    });

    test('maps HDOP value', () {
      final data = makeTestData(hdop: 1.2);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.gps.hdop, closeTo(1.2, 0.01));
    });
  });

  // ===========================================================================
  // Motion data mapping
  // ===========================================================================

  group('RaceBoxAdapter motion mapping', () {
    test('maps gForceX to gForceLateral', () {
      final data = makeTestData(gForceX: 1.25);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.hasMotion(), isTrue);
      expect(frame.motion.gForceLateral, closeTo(1.25, 0.01));
    });

    test('maps gForceY to gForceLongitudinal', () {
      final data = makeTestData(gForceY: -0.85);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.motion.gForceLongitudinal, closeTo(-0.85, 0.01));
    });

    test('maps gForceZ to gForceVertical', () {
      final data = makeTestData(gForceZ: 0.98);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.motion.gForceVertical, closeTo(0.98, 0.01));
    });

    test('maps negative g-force values correctly', () {
      final data = makeTestData(gForceX: -1.5, gForceY: -2.0, gForceZ: -0.1);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.motion.gForceLateral, closeTo(-1.5, 0.01));
      expect(frame.motion.gForceLongitudinal, closeTo(-2.0, 0.01));
      expect(frame.motion.gForceVertical, closeTo(-0.1, 0.01));
    });

    test('maps zero g-forces', () {
      final data = makeTestData(gForceX: 0, gForceY: 0, gForceZ: 0);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.motion.gForceLateral, equals(0.0));
      expect(frame.motion.gForceLongitudinal, equals(0.0));
      expect(frame.motion.gForceVertical, equals(0.0));
    });
  });

  // ===========================================================================
  // Source type
  // ===========================================================================

  group('RaceBoxAdapter source type', () {
    test('sets sourceType to SOURCE_TYPE_RACEBOX_MINI', () {
      final data = makeTestData();
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.sourceType, equals(SourceType.SOURCE_TYPE_RACEBOX_MINI));
    });
  });

  // ===========================================================================
  // Timestamps
  // ===========================================================================

  group('RaceBoxAdapter timestamps', () {
    test('sets device timestamp from RaceBoxData timestamp', () {
      final ts = DateTime.utc(2025, 3, 15, 14, 30, 45, 123);
      final data = makeTestData(timestamp: ts);
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.hasDeviceTimestamp(), isTrue);
      // Check seconds match (ms → seconds truncation)
      expect(
        frame.deviceTimestamp.seconds.toInt(),
        equals(ts.millisecondsSinceEpoch ~/ 1000),
      );
      // Check nanos encode the sub-second milliseconds
      expect(
        frame.deviceTimestamp.nanos,
        equals((ts.millisecondsSinceEpoch % 1000) * 1000000),
      );
    });

    test('sets arrival timestamp (non-null)', () {
      final data = makeTestData();
      final beforeCall = DateTime.now();
      final frame = RaceBoxAdapter.fromRaceBoxData(data);
      final afterCall = DateTime.now();

      expect(frame.hasArrivalTimestamp(), isTrue);

      // The arrival timestamp seconds should be between before and after.
      final arrivalSec = frame.arrivalTimestamp.seconds.toInt();
      expect(
        arrivalSec,
        greaterThanOrEqualTo(beforeCall.millisecondsSinceEpoch ~/ 1000),
      );
      expect(
        arrivalSec,
        lessThanOrEqualTo(afterCall.millisecondsSinceEpoch ~/ 1000),
      );
    });
  });

  // ===========================================================================
  // rawPayload
  // ===========================================================================

  group('RaceBoxAdapter rawPayload', () {
    test('sets rawPayload to empty bytes', () {
      final data = makeTestData();
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.rawPayload, isEmpty);
    });
  });

  // ===========================================================================
  // Engine / Fuel are NOT set
  // ===========================================================================

  group('RaceBoxAdapter does not populate engine or fuel', () {
    test('engine sub-message is not set', () {
      final data = makeTestData();
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.hasEngine(), isFalse);
    });

    test('fuel sub-message is not set', () {
      final data = makeTestData();
      final frame = RaceBoxAdapter.fromRaceBoxData(data);

      expect(frame.hasFuel(), isFalse);
    });
  });
}
