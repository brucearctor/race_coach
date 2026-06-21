import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/racebox/data/racebox_protocol.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper: build a valid GPS packet from known values.
  //
  // Packet layout (little-endian):
  //   [0-1]   Header:    0x24 0x24
  //   [2]     MsgType:   0x01 (GPS data)
  //   [3-4]   PayloadLen: uint16 — bytes 5..end
  //   [5-8]   Timestamp:  uint32 ms since epoch
  //   [9-12]  Latitude:   int32, degrees × 1e7
  //   [13-16] Longitude:  int32, degrees × 1e7
  //   [17-20] Speed:      uint32, mm/s
  //   [21-24] Heading:    uint32, degrees × 1e5
  //   [25-28] Altitude:   int32, mm
  //   [29]    Satellites: uint8
  //   [30]    HDOP:       uint8, × 0.1
  //   [31-32] G-force X:  int16, milli-g
  //   [33-34] G-force Y:  int16, milli-g
  //   [35-36] G-force Z:  int16, milli-g
  // ---------------------------------------------------------------------------

  /// Builds a valid 37-byte GPS packet with the given field values.
  List<int> buildGpsPacket({
    int timestampMs = 1000000,
    int latRaw = 375375300, // 37.53753 × 1e7
    int lonRaw = -1223250800, // -122.32508 × 1e7
    int speedMmPerS = 27778, // 27.778 m/s ≈ 100 km/h
    int headingRaw = 18000000, // 180.0 × 1e5
    int altMm = 50000, // 50 m
    int satellites = 12,
    int hdopRaw = 8, // 0.8
    int gForceXMilliG = 500, // 0.5 g
    int gForceYMilliG = -300, // -0.3 g
    int gForceZMilliG = 980, // 0.98 g
  }) {
    final payloadLength = 32; // bytes 5..36 = 32 bytes
    final buf = ByteData(37);

    // Header
    buf.setUint8(0, 0x24);
    buf.setUint8(1, 0x24);
    // Message type
    buf.setUint8(2, 0x01);
    // Payload length (little-endian)
    buf.setUint16(3, payloadLength, Endian.little);
    // Timestamp
    buf.setUint32(5, timestampMs, Endian.little);
    // Latitude (signed)
    buf.setInt32(9, latRaw, Endian.little);
    // Longitude (signed)
    buf.setInt32(13, lonRaw, Endian.little);
    // Speed
    buf.setUint32(17, speedMmPerS, Endian.little);
    // Heading
    buf.setUint32(21, headingRaw, Endian.little);
    // Altitude (signed)
    buf.setInt32(25, altMm, Endian.little);
    // Satellites
    buf.setUint8(29, satellites);
    // HDOP
    buf.setUint8(30, hdopRaw);
    // G-forces (signed int16)
    buf.setInt16(31, gForceXMilliG, Endian.little);
    buf.setInt16(33, gForceYMilliG, Endian.little);
    buf.setInt16(35, gForceZMilliG, Endian.little);

    return buf.buffer.asUint8List().toList();
  }

  // ===========================================================================
  // isValidPacket
  // ===========================================================================

  group('RaceBoxProtocol.isValidPacket', () {
    test('returns true for a valid GPS packet with correct header', () {
      final packet = buildGpsPacket();
      expect(RaceBoxProtocol.isValidPacket(packet), isTrue);
    });

    test('returns false for data shorter than minGpsPacketLength', () {
      expect(RaceBoxProtocol.isValidPacket([0x24, 0x24, 0x01]), isFalse);
      expect(RaceBoxProtocol.isValidPacket([]), isFalse);
      expect(RaceBoxProtocol.isValidPacket(List.filled(36, 0)), isFalse);
    });

    test('returns false when first header byte is wrong', () {
      final packet = buildGpsPacket();
      packet[0] = 0x00; // break header byte 1
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when second header byte is wrong', () {
      final packet = buildGpsPacket();
      packet[1] = 0xFF; // break header byte 2
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when message type is not GPS (0x01)', () {
      final packet = buildGpsPacket();
      packet[2] = 0x02; // non-GPS message type
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when payload length exceeds actual data', () {
      final packet = buildGpsPacket();
      // Set payload length to something huge (little-endian)
      final buf = ByteData(2);
      buf.setUint16(0, 9999, Endian.little);
      packet[3] = buf.getUint8(0);
      packet[4] = buf.getUint8(1);
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });
  });

  // ===========================================================================
  // parsePacket
  // ===========================================================================

  group('RaceBoxProtocol.parsePacket', () {
    test('parses a valid GPS packet with known values', () {
      // Build a packet with known test values.
      final packet = buildGpsPacket(
        timestampMs: 1718000000, // arbitrary known ms
        latRaw: 375375300, // 37.53753°
        lonRaw: -1223250800, // -122.32508°
        speedMmPerS: 27778, // 27.778 m/s → 100.0008 km/h
        headingRaw: 18000000, // 180.0°
        altMm: 50000, // 50.0 m
        satellites: 12,
        hdopRaw: 8, // 0.8
        gForceXMilliG: 500, // 0.5 g
        gForceYMilliG: -300, // -0.3 g
        gForceZMilliG: 980, // 0.98 g
      );

      final result = RaceBoxProtocol.parsePacket(packet);
      expect(result, isNotNull);

      // Latitude: 375375300 / 1e7 = 37.53753
      expect(result!.latitude, closeTo(37.53753, 1e-5));

      // Longitude: -1223250800 / 1e7 = -122.32508
      expect(result.longitude, closeTo(-122.32508, 1e-5));

      // Speed: 27778 mm/s → 27.778 m/s → 100.0008 km/h
      expect(result.speedKmh, closeTo(100.0, 0.1));

      // Heading: 18000000 / 1e5 = 180.0
      expect(result.headingDegrees, closeTo(180.0, 0.01));

      // Altitude: 50000 mm → 50.0 m
      expect(result.altitudeMeters, closeTo(50.0, 0.01));

      // Satellites
      expect(result.satellites, equals(12));

      // HDOP: 8 × 0.1 = 0.8
      expect(result.hdop, closeTo(0.8, 0.01));

      // G-forces: milli-g → g
      expect(result.gForceX, closeTo(0.5, 0.001));
      expect(result.gForceY, closeTo(-0.3, 0.001));
      expect(result.gForceZ, closeTo(0.98, 0.001));

      // Timestamp
      expect(
        result.timestamp,
        equals(DateTime.fromMillisecondsSinceEpoch(1718000000, isUtc: true)),
      );
    });

    test('parses negative latitude and longitude correctly', () {
      // Southern hemisphere, eastern hemisphere
      final packet = buildGpsPacket(
        latRaw: -338800000, // -33.88°
        lonRaw: 1512100000, // 151.21° (Sydney, AU)
      );

      final result = RaceBoxProtocol.parsePacket(packet);
      expect(result, isNotNull);
      expect(result!.latitude, closeTo(-33.88, 1e-4));
      expect(result.longitude, closeTo(151.21, 1e-4));
    });

    test('parses zero speed and g-forces', () {
      final packet = buildGpsPacket(
        speedMmPerS: 0,
        gForceXMilliG: 0,
        gForceYMilliG: 0,
        gForceZMilliG: 0,
      );

      final result = RaceBoxProtocol.parsePacket(packet);
      expect(result, isNotNull);
      expect(result!.speedKmh, equals(0.0));
      expect(result.gForceX, equals(0.0));
      expect(result.gForceY, equals(0.0));
      expect(result.gForceZ, equals(0.0));
    });

    test('returns null for non-GPS message type', () {
      final packet = buildGpsPacket();
      packet[2] = 0x02; // Change to a different message type
      expect(RaceBoxProtocol.parsePacket(packet), isNull);
    });

    test('returns null for too-short packets', () {
      expect(RaceBoxProtocol.parsePacket([]), isNull);
      expect(RaceBoxProtocol.parsePacket([0x24, 0x24]), isNull);
      expect(
        RaceBoxProtocol.parsePacket(List.filled(10, 0)),
        isNull,
      );
    });

    test('returns null for invalid header bytes', () {
      final packet = buildGpsPacket();
      packet[0] = 0x00;
      expect(RaceBoxProtocol.parsePacket(packet), isNull);
    });

    test('handles a packet with extra trailing bytes gracefully', () {
      // A valid packet with extra bytes appended should still parse.
      final packet = buildGpsPacket();
      final extended = [...packet, 0x00, 0x00, 0xFF, 0xFF];
      final result = RaceBoxProtocol.parsePacket(extended);
      expect(result, isNotNull);
      expect(result!.latitude, closeTo(37.53753, 1e-5));
    });
  });
}
