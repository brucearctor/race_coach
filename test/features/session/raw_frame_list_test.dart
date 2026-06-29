import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/features/session/domain/raw_frame_list.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper: build a TelemetryFrame with known GPS values.
  // ---------------------------------------------------------------------------

  TelemetryFrame makeFrame({
    double latitude = 37.0,
    double longitude = -122.0,
    double speedKmh = 100.0,
    int satellites = 12,
    double gForceLateral = 0.5,
    SourceType sourceType = SourceType.SOURCE_TYPE_RACEBOX_MINI,
  }) {
    final gps = GpsData()
      ..latitude = latitude
      ..longitude = longitude
      ..speedKmh = speedKmh
      ..satellites = satellites;

    final motion = MotionData()..gForceLateral = gForceLateral;

    return TelemetryFrame()
      ..gps = gps
      ..motion = motion
      ..sourceType = sourceType;
  }

  // ===========================================================================
  // Empty cases
  // ===========================================================================

  group('Empty encoding/decoding', () {
    test('encoding an empty list returns empty bytes', () {
      final bytes = encodeRawFrames([]);
      expect(bytes, isEmpty);
      expect(bytes.length, equals(0));
    });

    test('decoding empty bytes returns an empty list', () {
      final frames = decodeRawFrames(Uint8List(0));
      expect(frames, isEmpty);
    });
  });

  // ===========================================================================
  // Round-trip: single frame
  // ===========================================================================

  group('Round-trip: single frame', () {
    test('encode then decode produces identical frame', () {
      final original = makeFrame(
        latitude: 39.538,
        longitude: -122.325,
        speedKmh: 145.5,
        satellites: 16,
        gForceLateral: 1.2,
      );

      final encoded = encodeRawFrames([original]);
      expect(encoded.length, greaterThan(4)); // At least the length header

      final decoded = decodeRawFrames(encoded);
      expect(decoded.length, equals(1));

      final result = decoded[0];
      expect(result.gps.latitude, equals(original.gps.latitude));
      expect(result.gps.longitude, equals(original.gps.longitude));
      expect(result.gps.speedKmh, closeTo(original.gps.speedKmh, 0.1));
      expect(result.gps.satellites, equals(original.gps.satellites));
      expect(
        result.motion.gForceLateral,
        closeTo(original.motion.gForceLateral, 0.01),
      );
      expect(result.sourceType, equals(SourceType.SOURCE_TYPE_RACEBOX_MINI));
    });
  });

  // ===========================================================================
  // Round-trip: multiple frames
  // ===========================================================================

  group('Round-trip: multiple frames', () {
    test('encode then decode preserves all frames in order', () {
      final frames = [
        makeFrame(latitude: 37.0, speedKmh: 80.0),
        makeFrame(latitude: 38.0, speedKmh: 120.0),
        makeFrame(latitude: 39.0, speedKmh: 160.0),
      ];

      final encoded = encodeRawFrames(frames);
      final decoded = decodeRawFrames(encoded);

      expect(decoded.length, equals(3));

      for (var i = 0; i < frames.length; i++) {
        expect(decoded[i].gps.latitude, equals(frames[i].gps.latitude));
        expect(decoded[i].gps.speedKmh, closeTo(frames[i].gps.speedKmh, 0.1));
      }
    });

    test(
      'handles frames with different sizes (some with motion, some without)',
      () {
        // Frame with GPS only
        final gpsOnly = TelemetryFrame()
          ..gps = (GpsData()
            ..latitude = 37.0
            ..longitude = -122.0);

        // Frame with GPS + motion
        final gpsAndMotion = TelemetryFrame()
          ..gps = (GpsData()
            ..latitude = 38.0
            ..longitude = -121.0
            ..speedKmh = 100.0
            ..headingDegrees = 90.0
            ..altitudeMeters = 50.0
            ..satellites = 14
            ..hdop = 0.8)
          ..motion = (MotionData()
            ..gForceLateral = 0.5
            ..gForceLongitudinal = -0.3
            ..gForceVertical = 0.98);

        // Frame with minimal data
        final minimal = TelemetryFrame()
          ..sourceType = SourceType.SOURCE_TYPE_PHONE_GPS;

        final encoded = encodeRawFrames([gpsOnly, gpsAndMotion, minimal]);
        final decoded = decodeRawFrames(encoded);

        expect(decoded.length, equals(3));

        // First frame: GPS only
        expect(decoded[0].gps.latitude, equals(37.0));
        expect(decoded[0].hasMotion(), isFalse);

        // Second frame: GPS + motion
        expect(decoded[1].gps.latitude, equals(38.0));
        expect(decoded[1].gps.satellites, equals(14));
        expect(decoded[1].motion.gForceLateral, closeTo(0.5, 0.01));

        // Third frame: minimal
        expect(decoded[2].sourceType, equals(SourceType.SOURCE_TYPE_PHONE_GPS));
      },
    );
  });

  // ===========================================================================
  // Edge cases
  // ===========================================================================

  group('Edge cases', () {
    test('large batch of frames round-trips correctly', () {
      final frames = List.generate(100, (i) {
        return makeFrame(latitude: 37.0 + i * 0.001, speedKmh: 50.0 + i);
      });

      final encoded = encodeRawFrames(frames);
      final decoded = decodeRawFrames(encoded);

      expect(decoded.length, equals(100));
      expect(decoded.first.gps.latitude, closeTo(37.0, 0.01));
      expect(decoded.last.gps.latitude, closeTo(37.099, 0.01));
    });

    test('truncated data decodes gracefully (partial header)', () {
      // Only 2 bytes — can't read a 4-byte length header
      final truncated = Uint8List.fromList([0x00, 0x05]);
      final decoded = decodeRawFrames(truncated);
      expect(decoded, isEmpty);
    });

    test(
      'truncated data decodes gracefully (header says more data than exists)',
      () {
        // Valid 4-byte header claiming 1000 bytes of payload, but only 4 bytes total
        final buf = ByteData(4);
        buf.setUint32(0, 1000, Endian.big);
        final truncated = buf.buffer.asUint8List();

        final decoded = decodeRawFrames(truncated);
        expect(decoded, isEmpty);
      },
    );

    test('source type is preserved through round-trip', () {
      for (final st in [
        SourceType.SOURCE_TYPE_RACEBOX_MINI,
        SourceType.SOURCE_TYPE_PHONE_GPS,
        SourceType.SOURCE_TYPE_OBD_BLE,
        SourceType.SOURCE_TYPE_VBOX,
      ]) {
        final frame = TelemetryFrame()..sourceType = st;
        final encoded = encodeRawFrames([frame]);
        final decoded = decodeRawFrames(encoded);
        expect(decoded.first.sourceType, equals(st), reason: 'Failed for $st');
      }
    });
  });
}
