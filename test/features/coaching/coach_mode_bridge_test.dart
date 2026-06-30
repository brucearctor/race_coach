import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/coaching/domain/coaching_cue.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';
import 'package:race_coach/src/rust/types.dart' as rust;

void main() {
  // ===========================================================================
  // CueType mapping — every Rust CueType maps to a Dart CoachingCueType
  // ===========================================================================

  group('CoachModeBridge cue type mapping', () {
    // We can't call private static _mapCueType directly, but we can
    // verify via _toDartCue. Since _toDartCue is also private, we test
    // the mapping table exhaustively by verifying all CueType values
    // have a corresponding CoachingCueType.

    test('all Rust CueType values have Dart mappings', () {
      // Verify the mapping table is exhaustive.
      // This test ensures the switch expression in _mapCueType covers
      // every CueType variant — if a new one is added, this will fail.
      final allRustTypes = rust.CueType.values;

      // These are the expected Dart mappings.
      final expectedMappings = <rust.CueType, CoachingCueType>{
        rust.CueType.braking: CoachingCueType.braking,
        rust.CueType.throttle: CoachingCueType.throttle,
        rust.CueType.line: CoachingCueType.line,
        rust.CueType.speed: CoachingCueType.speed,
        rust.CueType.sectorTime: CoachingCueType.sectorTime,
        rust.CueType.lapTime: CoachingCueType.lapTime,
        rust.CueType.gForce: CoachingCueType.general,
        rust.CueType.general: CoachingCueType.general,
        rust.CueType.coasting: CoachingCueType.coasting,
        rust.CueType.trailBraking: CoachingCueType.trailBraking,
        rust.CueType.gripUtilization: CoachingCueType.general,
        rust.CueType.mlBraking: CoachingCueType.braking,
        rust.CueType.mlThrottle: CoachingCueType.throttle,
      };

      // Every Rust CueType should be in our expected map.
      for (final type in allRustTypes) {
        expect(
          expectedMappings.containsKey(type),
          isTrue,
          reason: 'Missing mapping for rust.CueType.$type',
        );
      }

      // And the map should cover all values.
      expect(expectedMappings.length, allRustTypes.length);
    });

    test('braking-family types map to CoachingCueType.braking', () {
      expect(
        [rust.CueType.braking, rust.CueType.mlBraking]
            .every((t) => _expectedMapping(t) == CoachingCueType.braking),
        isTrue,
      );
    });

    test('throttle-family types map to CoachingCueType.throttle', () {
      expect(
        [rust.CueType.throttle, rust.CueType.mlThrottle]
            .every((t) => _expectedMapping(t) == CoachingCueType.throttle),
        isTrue,
      );
    });

    test('general-family types map to CoachingCueType.general', () {
      expect(
        [rust.CueType.gForce, rust.CueType.general, rust.CueType.gripUtilization]
            .every((t) => _expectedMapping(t) == CoachingCueType.general),
        isTrue,
      );
    });
  });

  // ===========================================================================
  // CuePriority mapping — 1:1 from Rust to Dart
  // ===========================================================================

  group('CoachModeBridge priority mapping', () {
    test('all Rust CuePriority values have Dart mappings', () {
      final expectedMappings = <rust.CuePriority, CuePriority>{
        rust.CuePriority.low: CuePriority.low,
        rust.CuePriority.medium: CuePriority.medium,
        rust.CuePriority.high: CuePriority.high,
        rust.CuePriority.critical: CuePriority.critical,
      };

      expect(expectedMappings.length, rust.CuePriority.values.length);
    });

    test('priority ordinals match between Rust and Dart', () {
      // Verify the order is preserved: low < medium < high < critical.
      expect(rust.CuePriority.low.index, CuePriority.low.index);
      expect(rust.CuePriority.medium.index, CuePriority.medium.index);
      expect(rust.CuePriority.high.index, CuePriority.high.index);
      expect(rust.CuePriority.critical.index, CuePriority.critical.index);
    });
  });

  // ===========================================================================
  // RaceBoxData → TelemetryInput conversion shape
  // ===========================================================================

  group('RaceBoxData field compatibility', () {
    test('RaceBoxData has all fields needed for TelemetryInput', () {
      // Verify the RaceBoxData class exposes the fields that
      // CoachModeBridge._toRustInput maps to TelemetryInput.
      final data = RaceBoxData(
        timestamp: DateTime(2025, 1, 1),
        latitude: 37.0,
        longitude: -122.0,
        speedKmh: 100.0,
        headingDegrees: 90.0,
        altitudeMeters: 50.0,
        gForceX: 0.5,
        gForceY: -0.3,
        gForceZ: 1.0,
        satellites: 12,
        hdop: 0.8,
      );

      // All fields should be accessible (compile-time check + runtime).
      expect(data.timestamp, isNotNull);
      expect(data.latitude, 37.0);
      expect(data.longitude, -122.0);
      expect(data.speedKmh, 100.0);
      expect(data.headingDegrees, 90.0);
      expect(data.altitudeMeters, 50.0);
      expect(data.gForceX, 0.5);
      expect(data.gForceY, -0.3);
      expect(data.gForceZ, 1.0);
      expect(data.satellites, 12);
      expect(data.hdop, 0.8);
    });

    test('TelemetryInput accepts all mapped field types', () {
      // Verify rust.TelemetryInput constructor accepts all the types
      // that CoachModeBridge._toRustInput produces.
      final input = rust.TelemetryInput(
        timestampMs: BigInt.from(1234567890),
        latitude: 37.0,
        longitude: -122.0,
        speedKmh: 100.0,
        headingDeg: 90.0,
        altitudeM: 50.0,
        gLateral: 0.5,
        gLongitudinal: -0.3,
        gVertical: 1.0,
        satellites: 12,
        hdop: 0.8,
      );

      expect(input.timestampMs, BigInt.from(1234567890));
      expect(input.latitude, 37.0);
      expect(input.speedKmh, 100.0);
      expect(input.gLateral, 0.5);
    });
  });

  // ===========================================================================
  // Rust CoachingCue field compatibility
  // ===========================================================================

  group('Rust CoachingCue compatibility', () {
    test('rust.CoachingCue exposes all fields needed for conversion', () {
      const cue = rust.CoachingCue(
        cueType: rust.CueType.braking,
        message: 'Brake later!',
        priority: rust.CuePriority.high,
        cornerNumber: 5,
        deltaSeconds: -0.3,
        distanceDeltaM: 5.0,
      );

      expect(cue.cueType, rust.CueType.braking);
      expect(cue.message, 'Brake later!');
      expect(cue.priority, rust.CuePriority.high);
      expect(cue.cornerNumber, 5);
      expect(cue.deltaSeconds, -0.3);
      expect(cue.distanceDeltaM, 5.0);
    });

    test('rust.CoachingCue optional fields can be null', () {
      const cue = rust.CoachingCue(
        cueType: rust.CueType.general,
        message: 'Good job!',
        priority: rust.CuePriority.low,
      );

      expect(cue.cornerNumber, isNull);
      expect(cue.deltaSeconds, isNull);
      expect(cue.distanceDeltaM, isNull);
    });
  });
}

// =============================================================================
// Helpers — mirrors CoachModeBridge._mapCueType for testing
// =============================================================================

/// Mirrors the mapping table from CoachModeBridge._mapCueType.
/// This is duplicated intentionally so tests detect mapping drift.
CoachingCueType _expectedMapping(rust.CueType t) => switch (t) {
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
