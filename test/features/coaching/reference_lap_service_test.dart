import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'package:race_coach/features/coaching/data/reference_lap_service.dart';
import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/src/rust/types.dart' as rust;

void main() {
  // ===========================================================================
  // ReferenceLapState
  // ===========================================================================

  group('ReferenceLapState', () {
    test('empty() creates default state', () {
      final state = ReferenceLapState.empty();
      expect(state.sessionId, isNull);
      expect(state.lapNumber, isNull);
      expect(state.lapTimeSeconds, isNull);
      expect(state.isLoaded, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final state = ReferenceLapState(
        sessionId: 'sess-1',
        lapNumber: 3,
        lapTimeSeconds: 92.5,
        isLoaded: true,
      );

      final updated = state.copyWith(isLoading: true);

      expect(updated.sessionId, 'sess-1');
      expect(updated.lapNumber, 3);
      expect(updated.lapTimeSeconds, 92.5);
      expect(updated.isLoaded, isTrue);
      expect(updated.isLoading, isTrue);
    });

    test('copyWith clears error when not provided', () {
      final state = ReferenceLapState(
        error: 'something failed',
        isLoading: true,
      );

      // copyWith without error should clear it (error defaults to null).
      final updated = state.copyWith(isLoading: false);
      expect(updated.error, isNull);
    });

    group('formattedLapTime', () {
      test('returns placeholder for null lap time', () {
        final state = ReferenceLapState.empty();
        expect(state.formattedLapTime, '--:--.--');
      });

      test('returns placeholder for zero lap time', () {
        const state = ReferenceLapState(lapTimeSeconds: 0.0);
        expect(state.formattedLapTime, '--:--.--');
      });

      test('returns placeholder for negative lap time', () {
        const state = ReferenceLapState(lapTimeSeconds: -1.0);
        expect(state.formattedLapTime, '--:--.--');
      });

      test('formats sub-minute time as seconds', () {
        const state = ReferenceLapState(lapTimeSeconds: 45.3);
        expect(state.formattedLapTime, '45.3');
      });

      test('formats time with minutes', () {
        const state = ReferenceLapState(lapTimeSeconds: 92.5);
        expect(state.formattedLapTime, '1:32.5');
      });

      test('formats time with leading zeros on seconds', () {
        const state = ReferenceLapState(lapTimeSeconds: 63.1);
        expect(state.formattedLapTime, '1:03.1');
      });

      test('formats exact minute boundary', () {
        const state = ReferenceLapState(lapTimeSeconds: 60.0);
        expect(state.formattedLapTime, '1:00.0');
      });

      test('formats multi-minute time', () {
        const state = ReferenceLapState(lapTimeSeconds: 142.7);
        expect(state.formattedLapTime, '2:22.7');
      });
    });
  });

  // ===========================================================================
  // protoFrameToRustInput
  // ===========================================================================

  group('protoFrameToRustInput', () {
    TelemetryFrame _makeFrame({
      double lat = 37.123,
      double lng = -122.456,
      double speedKmh = 150.0,
      double headingDeg = 90.0,
      double altitudeM = 100.0,
      int satellites = 12,
      double hdop = 0.8,
      double? gLat,
      double? gLon,
      double? gVert,
      int? deviceTimestampSec,
      int? deviceTimestampNanos,
      int? arrivalTimestampSec,
      int? arrivalTimestampNanos,
    }) {
      final frame = TelemetryFrame();

      // GPS data (always set).
      frame.gps = GpsData()
        ..latitude = lat
        ..longitude = lng
        ..speedKmh = speedKmh
        ..headingDegrees = headingDeg
        ..altitudeMeters = altitudeM
        ..satellites = satellites
        ..hdop = hdop;

      // Motion data (optional).
      if (gLat != null || gLon != null || gVert != null) {
        frame.motion = MotionData()
          ..gForceLateral = gLat ?? 0.0
          ..gForceLongitudinal = gLon ?? 0.0
          ..gForceVertical = gVert ?? 1.0;
      }

      // Device timestamp (optional).
      if (deviceTimestampSec != null) {
        frame.deviceTimestamp = Timestamp()
          ..seconds = Int64(deviceTimestampSec)
          ..nanos = deviceTimestampNanos ?? 0;
      }

      // Arrival timestamp (optional).
      if (arrivalTimestampSec != null) {
        frame.arrivalTimestamp = Timestamp()
          ..seconds = Int64(arrivalTimestampSec)
          ..nanos = arrivalTimestampNanos ?? 0;
      }

      return frame;
    }

    test('maps GPS fields correctly', () {
      final frame = _makeFrame(
        lat: 37.123,
        lng: -122.456,
        speedKmh: 180.5,
        headingDeg: 270.0,
        altitudeM: 50.0,
        satellites: 15,
        hdop: 0.6,
      );

      final result = protoFrameToRustInput(frame);

      expect(result.latitude, 37.123);
      expect(result.longitude, -122.456);
      expect(result.speedKmh, 180.5);
      expect(result.headingDeg, 270.0);
      expect(result.altitudeM, 50.0);
      expect(result.satellites, 15);
      expect(result.hdop, 0.6);
    });

    test('maps motion data when present', () {
      final frame = _makeFrame(
        gLat: 1.2,
        gLon: -0.8,
        gVert: 0.95,
      );

      final result = protoFrameToRustInput(frame);

      expect(result.gLateral, 1.2);
      expect(result.gLongitudinal, -0.8);
      expect(result.gVertical, 0.95);
    });

    test('defaults motion data to 0/1 when absent', () {
      final frame = _makeFrame(); // No motion data.

      final result = protoFrameToRustInput(frame);

      expect(result.gLateral, 0.0);
      expect(result.gLongitudinal, 0.0);
      expect(result.gVertical, 1.0);
    });

    test('prefers device_timestamp over arrival_timestamp', () {
      final frame = _makeFrame(
        deviceTimestampSec: 1000,
        deviceTimestampNanos: 500000000, // 500ms
        arrivalTimestampSec: 2000,
        arrivalTimestampNanos: 0,
      );

      final result = protoFrameToRustInput(frame);

      // device: 1000s + 500ms = 1000500ms
      expect(result.timestampMs, BigInt.from(1000500));
    });

    test('falls back to arrival_timestamp when no device_timestamp', () {
      final frame = _makeFrame(
        arrivalTimestampSec: 2000,
        arrivalTimestampNanos: 250000000, // 250ms
      );

      final result = protoFrameToRustInput(frame);

      // arrival: 2000s + 250ms = 2000250ms
      expect(result.timestampMs, BigInt.from(2000250));
    });

    test('timestamp is 0 when neither timestamp is set', () {
      final frame = _makeFrame(); // No timestamps.

      final result = protoFrameToRustInput(frame);

      expect(result.timestampMs, BigInt.zero);
    });

    test('handles nano-to-millisecond truncation correctly', () {
      // 999999999 nanos = 999ms (floor division by 1000000).
      final frame = _makeFrame(
        deviceTimestampSec: 1,
        deviceTimestampNanos: 999999999,
      );

      final result = protoFrameToRustInput(frame);

      // 1s + 999ms = 1999ms
      expect(result.timestampMs, BigInt.from(1999));
    });

    test('handles zero-second timestamp with nanos', () {
      final frame = _makeFrame(
        deviceTimestampSec: 0,
        deviceTimestampNanos: 100000000, // 100ms
      );

      final result = protoFrameToRustInput(frame);

      expect(result.timestampMs, BigInt.from(100));
    });
  });
}
