import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'package:race_coach/generated/racecoach/v1/session.pb.dart';
import 'package:race_coach/features/session/data/session_storage.dart';

void main() {
  group('SessionMeta proto roundtrip', () {
    test('empty SessionMeta survives roundtrip', () {
      final meta = SessionMeta();
      final bytes = meta.writeToBuffer();
      final restored = SessionMeta.fromBuffer(bytes);

      expect(restored.sessionId, isEmpty);
      expect(restored.driverName, isEmpty);
      expect(restored.notes, isEmpty);
      expect(restored.sessionType, SessionType.SESSION_TYPE_UNSPECIFIED);
    });

    test('fully populated SessionMeta survives roundtrip', () {
      final meta = SessionMeta()
        ..sessionId = '2026-06-30_091523_thunderhill-east'
        ..driverName = 'John'
        ..vehicle = (Vehicle()
          ..name = 'My Miata'
          ..make = 'Mazda'
          ..model = 'MX-5 ND'
          ..year = 2024
          ..vehicleClass = 'Spec Miata'
          ..weightKg = 1050.0
          ..powerHp = 181.0
          ..tireCompound = 'RE-71RS 200tw'
          ..tirePressures = (TirePressures()
            ..frontLeftPsi = 32.0
            ..frontRightPsi = 32.0
            ..rearLeftPsi = 30.0
            ..rearRightPsi = 30.0)
          ..notes = 'Stock suspension')
        ..conditions = (Conditions()
          ..surface = SurfaceCondition.SURFACE_CONDITION_DRY
          ..ambientTempC = 28.0
          ..trackTempC = 45.0
          ..humidityPct = 55.0)
        ..sessionType = SessionType.SESSION_TYPE_PRACTICE
        ..deviceInfo = (DeviceInfo()
          ..deviceModel = 'RaceBox Mini S'
          ..firmwareVersion = '2.1.0'
          ..sampleRateHz = 25)
        ..notes = 'Working on T3 entry'
        ..createdAt = Timestamp(seconds: Int64(1719741323), nanos: 0)
        ..updatedAt = Timestamp(seconds: Int64(1719741323), nanos: 0);

      final bytes = meta.writeToBuffer();
      final restored = SessionMeta.fromBuffer(bytes);

      expect(restored.sessionId, '2026-06-30_091523_thunderhill-east');
      expect(restored.driverName, 'John');
      expect(restored.vehicle.name, 'My Miata');
      expect(restored.vehicle.make, 'Mazda');
      expect(restored.vehicle.model, 'MX-5 ND');
      expect(restored.vehicle.year, 2024);
      expect(restored.vehicle.vehicleClass, 'Spec Miata');
      expect(restored.vehicle.weightKg, closeTo(1050.0, 0.1));
      expect(restored.vehicle.powerHp, closeTo(181.0, 0.1));
      expect(restored.vehicle.tireCompound, 'RE-71RS 200tw');
      expect(restored.vehicle.tirePressures.frontLeftPsi, closeTo(32.0, 0.1));
      expect(restored.vehicle.tirePressures.rearRightPsi, closeTo(30.0, 0.1));
      expect(restored.vehicle.notes, 'Stock suspension');
      expect(restored.conditions.surface, SurfaceCondition.SURFACE_CONDITION_DRY);
      expect(restored.conditions.ambientTempC, closeTo(28.0, 0.1));
      expect(restored.conditions.trackTempC, closeTo(45.0, 0.1));
      expect(restored.conditions.humidityPct, closeTo(55.0, 0.1));
      expect(restored.sessionType, SessionType.SESSION_TYPE_PRACTICE);
      expect(restored.deviceInfo.deviceModel, 'RaceBox Mini S');
      expect(restored.deviceInfo.sampleRateHz, 25);
      expect(restored.notes, 'Working on T3 entry');
    });

    test('binary size is small (~200 bytes)', () {
      final meta = SessionMeta()
        ..sessionId = '2026-06-30_thunderhill-east'
        ..driverName = 'John'
        ..vehicle = (Vehicle()
          ..name = 'My Miata'
          ..make = 'Mazda'
          ..model = 'MX-5 ND'
          ..year = 2024
          ..tireCompound = 'RE-71RS')
        ..conditions = (Conditions()
          ..surface = SurfaceCondition.SURFACE_CONDITION_DRY
          ..ambientTempC = 28.0)
        ..sessionType = SessionType.SESSION_TYPE_PRACTICE
        ..notes = 'Test session';

      final bytes = meta.writeToBuffer();
      // Should be well under 500 bytes for typical metadata.
      expect(bytes.length, lessThan(500));
    });
  });

  group('SessionMeta proto3 JSON', () {
    test('toProto3Json produces valid JSON', () {
      final meta = SessionMeta()
        ..driverName = 'Sarah'
        ..vehicle = (Vehicle()..name = 'GT3')
        ..conditions = (Conditions()
          ..surface = SurfaceCondition.SURFACE_CONDITION_WET)
        ..sessionType = SessionType.SESSION_TYPE_RACE;

      final json = meta.toProto3Json();
      expect(json, isA<Map>());

      // Should be parseable as JSON string.
      final jsonString = jsonEncode(json);
      expect(jsonString, contains('Sarah'));
      expect(jsonString, contains('GT3'));
    });

    test('mergeFromProto3Json restores all fields', () {
      final original = SessionMeta()
        ..driverName = 'John'
        ..vehicle = (Vehicle()
          ..name = 'Miata'
          ..weightKg = 1050.0)
        ..conditions = (Conditions()
          ..surface = SurfaceCondition.SURFACE_CONDITION_DAMP
          ..ambientTempC = 22.0)
        ..sessionType = SessionType.SESSION_TYPE_QUALIFYING;

      final json = original.toProto3Json();
      final restored = SessionMeta()..mergeFromProto3Json(json);

      expect(restored.driverName, 'John');
      expect(restored.vehicle.name, 'Miata');
      expect(restored.vehicle.weightKg, closeTo(1050.0, 0.1));
      expect(restored.conditions.surface,
          SurfaceCondition.SURFACE_CONDITION_DAMP);
      expect(restored.sessionType, SessionType.SESSION_TYPE_QUALIFYING);
    });
  });

  group('Backward compatibility', () {
    test('empty buffer produces valid defaults', () {
      // Simulates an old session with no metadata.
      final meta = SessionMeta.fromBuffer([]);

      expect(meta.sessionId, isEmpty);
      expect(meta.driverName, isEmpty);
      expect(meta.sessionType, SessionType.SESSION_TYPE_UNSPECIFIED);
      expect(meta.conditions.surface,
          SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED);
    });

    test('partial fields produce valid proto', () {
      // Only set driver name — everything else defaults.
      final meta = SessionMeta()..driverName = 'John';
      final bytes = meta.writeToBuffer();
      final restored = SessionMeta.fromBuffer(bytes);

      expect(restored.driverName, 'John');
      expect(restored.vehicle.name, isEmpty);
      expect(restored.vehicle.weightKg, 0.0);
      expect(restored.conditions.surface,
          SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED);
    });
  });

  group('Enum values', () {
    test('SurfaceCondition covers all expected values', () {
      expect(SurfaceCondition.values, hasLength(4));
      expect(SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED.value, 0);
      expect(SurfaceCondition.SURFACE_CONDITION_DRY.value, 1);
      expect(SurfaceCondition.SURFACE_CONDITION_DAMP.value, 2);
      expect(SurfaceCondition.SURFACE_CONDITION_WET.value, 3);
    });

    test('SessionType covers all expected values', () {
      expect(SessionType.values, hasLength(5));
      expect(SessionType.SESSION_TYPE_UNSPECIFIED.value, 0);
      expect(SessionType.SESSION_TYPE_PRACTICE.value, 1);
      expect(SessionType.SESSION_TYPE_QUALIFYING.value, 2);
      expect(SessionType.SESSION_TYPE_RACE.value, 3);
      expect(SessionType.SESSION_TYPE_TEST.value, 4);
    });
  });

  group('SessionSummary metadata fields', () {
    test('SessionSummary with metadata', () {
      final summary = SessionSummary(
        sessionId: 'test-session',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 30),
        lapCount: 12,
        bestLap: const Duration(seconds: 92, milliseconds: 300),
        driverName: 'John',
        vehicleName: 'MX-5 ND',
        surface: SurfaceCondition.SURFACE_CONDITION_DRY,
        sessionType: SessionType.SESSION_TYPE_PRACTICE,
      );

      expect(summary.driverName, 'John');
      expect(summary.vehicleName, 'MX-5 ND');
      expect(summary.surface, SurfaceCondition.SURFACE_CONDITION_DRY);
      expect(summary.sessionType, SessionType.SESSION_TYPE_PRACTICE);
    });

    test('SessionSummary without metadata (old session)', () {
      final summary = SessionSummary(
        sessionId: 'old-session',
        trackName: 'Laguna Seca',
        date: DateTime(2026, 5, 15),
        lapCount: 8,
      );

      expect(summary.driverName, isNull);
      expect(summary.vehicleName, isNull);
      expect(summary.surface, isNull);
      expect(summary.sessionType, isNull);
    });
  });
}
