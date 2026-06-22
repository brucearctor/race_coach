import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/racebox/data/racebox_protocol.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers for building UBX-format RaceBox packets
  // ---------------------------------------------------------------------------

  /// Set a little-endian int32 at [offset] in [buf].
  void setInt32LE(List<int> buf, int offset, int value) {
    final bd = ByteData(4)..setInt32(0, value, Endian.little);
    for (int i = 0; i < 4; i++) {
      buf[offset + i] = bd.getUint8(i);
    }
  }

  /// Set a little-endian uint16 at [offset] in [buf].
  void setUint16LE(List<int> buf, int offset, int value) {
    buf[offset] = value & 0xFF;
    buf[offset + 1] = (value >> 8) & 0xFF;
  }

  /// Set a little-endian int16 at [offset] in [buf].
  void setInt16LE(List<int> buf, int offset, int value) {
    final bd = ByteData(2)..setInt16(0, value, Endian.little);
    for (int i = 0; i < 2; i++) {
      buf[offset + i] = bd.getUint8(i);
    }
  }

  /// Compute Fletcher-16 checksum over class+id+length+payload (bytes 2..85).
  /// Returns [ckA, ckB].
  List<int> computeChecksum(List<int> packet) {
    int ckA = 0;
    int ckB = 0;
    for (int i = 2; i < 86; i++) {
      ckA = (ckA + packet[i]) & 0xFF;
      ckB = (ckB + ckA) & 0xFF;
    }
    return [ckA, ckB];
  }

  /// Builds a complete valid 88-byte UBX RaceBox data packet.
  ///
  /// Packet layout:
  ///   [0-1]   Header:      0xB5 0x62
  ///   [2]     Class:       0xFF (RaceBox)
  ///   [3]     ID:          0x01 (data message)
  ///   [4-5]   Length:      uint16 LE = 80 (0x50, 0x00)
  ///   [6-85]  Payload:     80 bytes (GPS + IMU data)
  ///   [86-87] Checksum:    Fletcher-16 (CK_A, CK_B)
  List<int> buildValidPacket({
    int year = 2025,
    int month = 6,
    int day = 15,
    int hour = 14,
    int minute = 30,
    int second = 45,
    int satellites = 12,
    int lonRaw = -1223250800, // -122.32508° × 1e7
    int latRaw = 375375300, //  37.53753°  × 1e7
    int altMm = 50000, //  50.0 m  in mm
    int speedMmPerS = 27778, //  27.778 m/s → ~100 km/h
    int headingRaw = 18000000, // 180.0° × 1e5
    int pdopRaw = 150, //  1.50  (× 0.01)
    int gForceXMilliG = 500, //  0.5 g
    int gForceYMilliG = -300, // -0.3 g
    int gForceZMilliG = 980, //  0.98 g
  }) {
    final packet = List<int>.filled(88, 0);

    // Header
    packet[0] = 0xB5;
    packet[1] = 0x62;

    // Class + ID
    packet[2] = 0xFF;
    packet[3] = 0x01;

    // Payload length = 80
    setUint16LE(packet, 4, 80);

    // --- Payload starts at file offset 6 ---
    const p = 6; // payload base offset

    // Year (payload offset 4-5 → file offset 10-11)
    setUint16LE(packet, p + 4, year);
    // Month (payload offset 6 → file offset 12)
    packet[p + 6] = month;
    // Day (payload offset 7 → file offset 13)
    packet[p + 7] = day;
    // Hour (payload offset 8 → file offset 14)
    packet[p + 8] = hour;
    // Minute (payload offset 9 → file offset 15)
    packet[p + 9] = minute;
    // Second (payload offset 10 → file offset 16)
    packet[p + 10] = second;

    // Satellites (payload offset 23 → file offset 29)
    packet[p + 23] = satellites;

    // Longitude int32 LE (payload offset 24-27 → file offset 30-33)
    setInt32LE(packet, p + 24, lonRaw);

    // Latitude int32 LE (payload offset 28-31 → file offset 34-37)
    setInt32LE(packet, p + 28, latRaw);

    // MSL Altitude int32 LE (payload offset 36-39 → file offset 42-45)
    setInt32LE(packet, p + 36, altMm);

    // Speed int32 LE (payload offset 48-51 → file offset 54-57)
    setInt32LE(packet, p + 48, speedMmPerS);

    // Heading int32 LE (payload offset 52-55 → file offset 58-61)
    setInt32LE(packet, p + 52, headingRaw);

    // PDOP uint16 LE (payload offset 64-65 → file offset 70-71)
    setUint16LE(packet, p + 64, pdopRaw);

    // G-force X int16 LE (payload offset 68-69 → file offset 74-75)
    setInt16LE(packet, p + 68, gForceXMilliG);

    // G-force Y int16 LE (payload offset 70-71 → file offset 76-77)
    setInt16LE(packet, p + 70, gForceYMilliG);

    // G-force Z int16 LE (payload offset 72-73 → file offset 78-79)
    setInt16LE(packet, p + 72, gForceZMilliG);

    // Compute and set checksum (bytes 86-87)
    final ck = computeChecksum(packet);
    packet[86] = ck[0];
    packet[87] = ck[1];

    return packet;
  }

  // ===========================================================================
  // isValidPacket
  // ===========================================================================

  group('RaceBoxProtocol.isValidPacket', () {
    test('returns true for a valid UBX packet', () {
      final packet = buildValidPacket();
      expect(RaceBoxProtocol.isValidPacket(packet), isTrue);
    });

    test('returns false for data shorter than 88 bytes', () {
      expect(RaceBoxProtocol.isValidPacket([0xB5, 0x62, 0xFF]), isFalse);
      expect(RaceBoxProtocol.isValidPacket([]), isFalse);
      expect(RaceBoxProtocol.isValidPacket(List.filled(87, 0)), isFalse);
    });

    test('returns false when first header byte is wrong', () {
      final packet = buildValidPacket();
      packet[0] = 0x00;
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when second header byte is wrong', () {
      final packet = buildValidPacket();
      packet[1] = 0x00;
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when class byte is wrong', () {
      final packet = buildValidPacket();
      packet[2] = 0x00; // expected 0xFF
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when message ID byte is wrong', () {
      final packet = buildValidPacket();
      packet[3] = 0x02; // expected 0x01
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when checksum is corrupted', () {
      final packet = buildValidPacket();
      // Corrupt the checksum bytes
      packet[86] = (packet[86] + 1) & 0xFF;
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });

    test('returns false when payload length field is wrong', () {
      final packet = buildValidPacket();
      // Change payload length from 80 to something else — need to recompute
      // checksum won't match anyway, but the length check should fail first.
      setUint16LE(packet, 4, 99);
      // Recompute checksum so only the length check can fail
      final ck = computeChecksum(packet);
      packet[86] = ck[0];
      packet[87] = ck[1];
      expect(RaceBoxProtocol.isValidPacket(packet), isFalse);
    });
  });

  // ===========================================================================
  // parsePacket
  // ===========================================================================

  group('RaceBoxProtocol.parsePacket', () {
    test('parses all fields from a valid packet correctly', () {
      final packet = buildValidPacket(
        year: 2025,
        month: 6,
        day: 15,
        hour: 14,
        minute: 30,
        second: 45,
        satellites: 12,
        lonRaw: -1223250800, // -122.32508°
        latRaw: 375375300, //  37.53753°
        altMm: 50000, //  50.0 m
        speedMmPerS: 27778, // → ~100 km/h
        headingRaw: 18000000, // 180.0°
        pdopRaw: 150, //  1.50
        gForceXMilliG: 500, //  0.5 g
        gForceYMilliG: -300, // -0.3 g
        gForceZMilliG: 980, //  0.98 g
      );

      final result = RaceBoxProtocol.parsePacket(packet);
      expect(result, isNotNull);

      // Timestamp
      expect(
        result!.timestamp,
        equals(DateTime.utc(2025, 6, 15, 14, 30, 45)),
      );

      // Latitude: 375375300 / 1e7 = 37.53753
      expect(result.latitude, closeTo(37.53753, 1e-5));

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

      // PDOP: 150 × 0.01 = 1.50 (mapped to hdop in RaceBoxData)
      expect(result.hdop, closeTo(1.50, 0.01));

      // G-forces: milli-g → g
      expect(result.gForceX, closeTo(0.5, 0.001));
      expect(result.gForceY, closeTo(-0.3, 0.001));
      expect(result.gForceZ, closeTo(0.98, 0.001));
    });

    test('parses negative latitude and longitude (southern/western)', () {
      final packet = buildValidPacket(
        latRaw: -338800000, // -33.88° (Sydney)
        lonRaw: 1512100000, //  151.21°
      );

      final result = RaceBoxProtocol.parsePacket(packet);
      expect(result, isNotNull);
      expect(result!.latitude, closeTo(-33.88, 1e-4));
      expect(result.longitude, closeTo(151.21, 1e-4));
    });

    test('parses zero speed and g-forces', () {
      final packet = buildValidPacket(
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

    test('returns null for invalid packet (bad header)', () {
      final packet = buildValidPacket();
      packet[0] = 0x00;
      expect(RaceBoxProtocol.parsePacket(packet), isNull);
    });

    test('returns null for too-short data', () {
      expect(RaceBoxProtocol.parsePacket([]), isNull);
      expect(RaceBoxProtocol.parsePacket([0xB5, 0x62]), isNull);
      expect(RaceBoxProtocol.parsePacket(List.filled(50, 0)), isNull);
    });

    test('returns null for bad checksum', () {
      final packet = buildValidPacket();
      packet[87] = (packet[87] + 1) & 0xFF;
      expect(RaceBoxProtocol.parsePacket(packet), isNull);
    });

    test('handles a packet with extra trailing bytes', () {
      final packet = buildValidPacket();
      final extended = [...packet, 0x00, 0x00, 0xFF, 0xFF, 0xAB];

      final result = RaceBoxProtocol.parsePacket(extended);
      expect(result, isNotNull);
      expect(result!.latitude, closeTo(37.53753, 1e-5));
      expect(result.longitude, closeTo(-122.32508, 1e-5));
      expect(result.satellites, equals(12));
    });

    test('parses negative altitude correctly', () {
      final packet = buildValidPacket(altMm: -5000); // -5.0 m (below sea level)

      final result = RaceBoxProtocol.parsePacket(packet);
      expect(result, isNotNull);
      expect(result!.altitudeMeters, closeTo(-5.0, 0.01));
    });

    test('parses high-speed values correctly', () {
      // 83333 mm/s = 83.333 m/s = 300 km/h
      final packet = buildValidPacket(speedMmPerS: 83333);

      final result = RaceBoxProtocol.parsePacket(packet);
      expect(result, isNotNull);
      expect(result!.speedKmh, closeTo(300.0, 0.1));
    });
  });
}
