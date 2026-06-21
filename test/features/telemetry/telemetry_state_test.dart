import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/features/telemetry/domain/telemetry_state.dart';

void main() {
  // ===========================================================================
  // TelemetryState.empty()
  // ===========================================================================

  group('TelemetryState.empty()', () {
    test('has null data slots', () {
      final state = TelemetryState.empty();
      expect(state.gps, isNull);
      expect(state.motion, isNull);
      expect(state.engine, isNull);
      expect(state.fuel, isNull);
    });

    test('has null updatedAt timestamps', () {
      final state = TelemetryState.empty();
      expect(state.gpsUpdatedAt, isNull);
      expect(state.motionUpdatedAt, isNull);
      expect(state.engineUpdatedAt, isNull);
      expect(state.fuelUpdatedAt, isNull);
    });

    test('has empty activeSources', () {
      final state = TelemetryState.empty();
      expect(state.activeSources, isEmpty);
    });
  });

  // ===========================================================================
  // Presence helpers (hasGps, hasMotion, etc.)
  // ===========================================================================

  group('Presence helpers', () {
    test('hasGps returns false when gps is null', () {
      final state = TelemetryState.empty();
      expect(state.hasGps, isFalse);
    });

    test('hasGps returns true when gps is set', () {
      final gps = GpsData()
        ..latitude = 37.0
        ..longitude = -122.0;
      final state = TelemetryState(gps: gps);
      expect(state.hasGps, isTrue);
    });

    test('hasMotion returns false when motion is null', () {
      final state = TelemetryState.empty();
      expect(state.hasMotion, isFalse);
    });

    test('hasMotion returns true when motion is set', () {
      final motion = MotionData()..gForceLateral = 0.5;
      final state = TelemetryState(motion: motion);
      expect(state.hasMotion, isTrue);
    });

    test('hasEngine returns false when engine is null', () {
      expect(TelemetryState.empty().hasEngine, isFalse);
    });

    test('hasEngine returns true when engine is set', () {
      final state = TelemetryState(engine: EngineData());
      expect(state.hasEngine, isTrue);
    });

    test('hasFuel returns false when fuel is null', () {
      expect(TelemetryState.empty().hasFuel, isFalse);
    });

    test('hasFuel returns true when fuel is set', () {
      final state = TelemetryState(fuel: FuelData());
      expect(state.hasFuel, isTrue);
    });
  });

  // ===========================================================================
  // Convenience accessors (speedKmh, speedMph, lateralG, longitudinalG)
  // ===========================================================================

  group('Speed accessors', () {
    test('speedKmh returns 0 when gps is null', () {
      expect(TelemetryState.empty().speedKmh, equals(0.0));
    });

    test('speedKmh returns value from gps data', () {
      final gps = GpsData()..speedKmh = 100.0;
      final state = TelemetryState(gps: gps);
      expect(state.speedKmh, equals(100.0));
    });

    test('speedMph returns 0 when gps is null', () {
      expect(TelemetryState.empty().speedMph, equals(0.0));
    });

    test('speedMph converts km/h to mph correctly', () {
      final gps = GpsData()..speedKmh = 100.0;
      final state = TelemetryState(gps: gps);
      // 100 km/h × 0.621371 = 62.1371 mph
      expect(state.speedMph, closeTo(62.1371, 0.001));
    });

    test('speedMph at 160 km/h is approximately 99.4 mph', () {
      final gps = GpsData()..speedKmh = 160.0;
      final state = TelemetryState(gps: gps);
      expect(state.speedMph, closeTo(99.42, 0.1));
    });
  });

  group('G-force accessors', () {
    test('lateralG returns 0 when motion is null', () {
      expect(TelemetryState.empty().lateralG, equals(0.0));
    });

    test('lateralG returns gForceLateral from motion data', () {
      final motion = MotionData()..gForceLateral = 1.2;
      final state = TelemetryState(motion: motion);
      expect(state.lateralG, closeTo(1.2, 0.01));
    });

    test('longitudinalG returns 0 when motion is null', () {
      expect(TelemetryState.empty().longitudinalG, equals(0.0));
    });

    test('longitudinalG returns gForceLongitudinal from motion data', () {
      final motion = MotionData()..gForceLongitudinal = -0.8;
      final state = TelemetryState(motion: motion);
      expect(state.longitudinalG, closeTo(-0.8, 0.01));
    });
  });

  // ===========================================================================
  // copyWith
  // ===========================================================================

  group('copyWith', () {
    test('preserves all fields when no arguments given', () {
      final gps = GpsData()..speedKmh = 50.0;
      final motion = MotionData()..gForceLateral = 0.3;
      final now = DateTime.now();
      final sources = [SourceType.SOURCE_TYPE_RACEBOX_MINI];

      final original = TelemetryState(
        gps: gps,
        motion: motion,
        gpsUpdatedAt: now,
        motionUpdatedAt: now,
        activeSources: sources,
      );

      final copy = original.copyWith();

      expect(copy.gps, same(gps));
      expect(copy.motion, same(motion));
      expect(copy.gpsUpdatedAt, equals(now));
      expect(copy.motionUpdatedAt, equals(now));
      expect(copy.activeSources, same(sources));
      expect(copy.engine, isNull);
      expect(copy.fuel, isNull);
    });

    test('updates only the specified fields', () {
      final gps = GpsData()..speedKmh = 50.0;
      final original = TelemetryState(gps: gps);

      final newGps = GpsData()..speedKmh = 120.0;
      final copy = original.copyWith(gps: newGps);

      expect(copy.gps!.speedKmh, equals(120.0));
      expect(copy.motion, isNull); // Unchanged
    });

    test('clearGps sets gps to null even when gps was set', () {
      final gps = GpsData()..speedKmh = 50.0;
      final original = TelemetryState(gps: gps);

      final copy = original.copyWith(clearGps: true);
      expect(copy.gps, isNull);
      expect(copy.hasGps, isFalse);
    });

    test('clearMotion sets motion to null even when motion was set', () {
      final motion = MotionData()..gForceLateral = 0.5;
      final original = TelemetryState(motion: motion);

      final copy = original.copyWith(clearMotion: true);
      expect(copy.motion, isNull);
      expect(copy.hasMotion, isFalse);
    });

    test('activeSources can be updated via copyWith', () {
      final original = TelemetryState.empty();
      final newSources = [
        SourceType.SOURCE_TYPE_RACEBOX_MINI,
        SourceType.SOURCE_TYPE_OBD_BLE,
      ];
      final copy = original.copyWith(activeSources: newSources);
      expect(copy.activeSources, equals(newSources));
      expect(copy.activeSources.length, equals(2));
    });
  });
}
