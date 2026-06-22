import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:race_coach/features/racebox/domain/racebox_data.dart';

/// Protocol parser for RaceBox Mini GPS devices.
///
/// The RaceBox Mini communicates over BLE using the Nordic UART Service (NUS).
/// It sends binary packets using a UBX-like protocol (0xB5 0x62 header) with
/// custom message class 0xFF for RaceBox data messages.
class RaceBoxProtocol {
  RaceBoxProtocol._(); // Prevent instantiation

  // -------------------------------------------------------------------------
  // Nordic UART Service (NUS) UUIDs
  // -------------------------------------------------------------------------

  /// NUS Service UUID.
  static const String serviceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';

  /// TX Characteristic UUID — subscribe for notifications (device → phone).
  static const String txCharUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  /// RX Characteristic UUID — write commands (phone → device).
  static const String rxCharUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  /// Pre-parsed [Uuid] for the NUS service, ready for scan filters.
  static final Uuid serviceUuidObj = Uuid.parse(serviceUuid);

  // -------------------------------------------------------------------------
  // UBX-like packet constants
  // -------------------------------------------------------------------------

  /// Two-byte sync/header that starts every RaceBox packet (UBX format).
  static const int headerByte1 = 0xB5;
  static const int headerByte2 = 0x62;

  /// Message class for RaceBox data messages.
  static const int msgClassRaceBox = 0xFF;

  /// Message ID for RaceBox GPS+IMU data.
  static const int msgIdDataMessage = 0x01;

  /// Minimum packet length: header(2) + class(1) + id(1) + len(2) + payload(80) + checksum(2) = 88.
  static const int minGpsPacketLength = 88;

  /// Expected payload length for RaceBox data messages.
  static const int dataMessagePayloadLength = 80;

  // -------------------------------------------------------------------------
  // Characteristic helpers
  // -------------------------------------------------------------------------

  /// Returns a [QualifiedCharacteristic] for the TX (notification) channel.
  static QualifiedCharacteristic txCharacteristic(String deviceId) {
    return QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(txCharUuid),
    );
  }

  /// Returns a [QualifiedCharacteristic] for the RX (write) channel.
  static QualifiedCharacteristic rxCharacteristic(String deviceId) {
    return QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(rxCharUuid),
    );
  }

  // -------------------------------------------------------------------------
  // Packet validation
  // -------------------------------------------------------------------------

  /// Returns `true` if [data] looks like a valid RaceBox data packet.
  static bool isValidPacket(List<int> data) {
    if (data.length < minGpsPacketLength) return false;
    if (data[0] != headerByte1 || data[1] != headerByte2) return false;
    if (data[2] != msgClassRaceBox) return false;
    if (data[3] != msgIdDataMessage) return false;

    // Verify payload length field (bytes 4-5, little-endian).
    final payloadLength = _getUint16(data, 4);
    if (payloadLength != dataMessagePayloadLength) return false;

    // Verify UBX checksum (Fletcher-16 over class, id, length, payload).
    if (!_verifyChecksum(data)) return false;

    return true;
  }

  // -------------------------------------------------------------------------
  // Packet parsing
  // -------------------------------------------------------------------------

  /// Parses a raw binary packet from the RaceBox Mini into [RaceBoxData].
  ///
  /// Returns `null` if the packet is invalid or not a data message.
  ///
  /// **UBX-like Packet structure (little-endian):**
  /// | Offset | Size | Field               | Unit / Notes              |
  /// |--------|------|---------------------|---------------------------|
  /// | 0–1    | 2    | Sync header         | 0xB5 0x62                 |
  /// | 2      | 1    | Message class       | 0xFF = RaceBox            |
  /// | 3      | 1    | Message ID          | 0x01 = Data message       |
  /// | 4–5    | 2    | Payload length      | uint16 LE (= 80)          |
  /// | 6–9    | 4    | iTOW                | uint32, ms GPS time of wk |
  /// | 10–11  | 2    | Year                | uint16                    |
  /// | 12     | 1    | Month               | uint8                     |
  /// | 13     | 1    | Day                 | uint8                     |
  /// | 14     | 1    | Hour                | uint8                     |
  /// | 15     | 1    | Minute              | uint8                     |
  /// | 16     | 1    | Second              | uint8                     |
  /// | 17     | 1    | Validity flags      | uint8                     |
  /// | 18–21  | 4    | Time accuracy       | uint32, ns                |
  /// | 22–25  | 4    | Nanoseconds         | int32                     |
  /// | 26     | 1    | Fix status          | uint8                     |
  /// | 27     | 1    | Fix status flags    | uint8                     |
  /// | 28     | 1    | Date/time flags     | uint8                     |
  /// | 29     | 1    | Num satellites      | uint8                     |
  /// | 30–33  | 4    | Longitude           | int32, degrees × 1e7      |
  /// | 34–37  | 4    | Latitude            | int32, degrees × 1e7      |
  /// | 38–41  | 4    | WGS84 Altitude      | int32, mm                 |
  /// | 42–45  | 4    | MSL Altitude        | int32, mm                 |
  /// | 46–49  | 4    | Horizontal accuracy | uint32, mm                |
  /// | 50–53  | 4    | Vertical accuracy   | uint32, mm                |
  /// | 54–57  | 4    | Speed               | int32, mm/s               |
  /// | 58–61  | 4    | Heading             | int32, degrees × 1e5      |
  /// | 62–65  | 4    | Speed accuracy      | uint32, mm/s              |
  /// | 66–69  | 4    | Heading accuracy    | uint32, degrees × 1e5     |
  /// | 70–71  | 2    | PDOP                | uint16, × 0.01            |
  /// | 72     | 1    | Lat/Lon flags       | uint8                     |
  /// | 73     | 1    | Battery status      | uint8                     |
  /// | 74–75  | 2    | G-force X           | int16, milli-g            |
  /// | 76–77  | 2    | G-force Y           | int16, milli-g            |
  /// | 78–79  | 2    | G-force Z           | int16, milli-g            |
  /// | 80–81  | 2    | Rotation rate X     | int16, degrees/s × 100    |
  /// | 82–83  | 2    | Rotation rate Y     | int16, degrees/s × 100    |
  /// | 84–85  | 2    | Rotation rate Z     | int16, degrees/s × 100    |
  /// | 86–87  | 2    | Checksum (CK_A/CK_B)                             |
  static RaceBoxData? parsePacket(List<int> data) {
    if (!isValidPacket(data)) return null;

    try {
      // Payload starts at offset 6 (after header, class, id, length).
      const p = 6; // payload offset

      // Date/time from individual fields.
      final year = _getUint16(data, p + 4);
      final month = data[p + 6];
      final day = data[p + 7];
      final hour = data[p + 8];
      final minute = data[p + 9];
      final second = data[p + 10];
      final timestamp = DateTime.utc(year, month, day, hour, minute, second);

      // Fix status (byte p+20, available if needed in the future).

      // Satellites
      final satellites = data[p + 23];

      // Longitude — int32, degrees × 1e7 (NOTE: lon comes before lat in RaceBox)
      final lonRaw = _getInt32(data, p + 24);
      final longitude = lonRaw / 1e7;

      // Latitude — int32, degrees × 1e7
      final latRaw = _getInt32(data, p + 28);
      final latitude = latRaw / 1e7;

      // MSL Altitude — int32, mm → m
      final altRaw = _getInt32(data, p + 36);
      final altitudeMeters = altRaw / 1000.0;

      // Speed — int32, mm/s → km/h
      final speedMmPerS = _getInt32(data, p + 48);
      final speedKmh = (speedMmPerS.abs() / 1000.0) * 3.6;

      // Heading — int32, degrees × 1e5
      final headingRaw = _getInt32(data, p + 52);
      final headingDegrees = headingRaw / 1e5;

      // PDOP — uint16, × 0.01
      final pdopRaw = _getUint16(data, p + 64);
      final hdop = pdopRaw * 0.01;

      // G-forces — int16, milli-g → g
      final gForceX = _getInt16(data, p + 68) / 1000.0;
      final gForceY = _getInt16(data, p + 70) / 1000.0;
      final gForceZ = _getInt16(data, p + 72) / 1000.0;

      return RaceBoxData(
        timestamp: timestamp,
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
    } catch (e) {
      debugPrint('[RaceBox] Parse exception: $e');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // UBX checksum (Fletcher-16)
  // -------------------------------------------------------------------------

  /// Verifies the UBX Fletcher-16 checksum.
  /// Checksum is computed over: class, id, length (2 bytes), payload.
  /// The two checksum bytes follow immediately after the payload.
  static bool _verifyChecksum(List<int> data) {
    final payloadLength = _getUint16(data, 4);
    final checksumOffset = 6 + payloadLength; // right after payload

    if (data.length < checksumOffset + 2) return false;

    int ckA = 0;
    int ckB = 0;

    // Checksum covers bytes 2..(checksumOffset-1): class, id, len, payload.
    for (int i = 2; i < checksumOffset; i++) {
      ckA = (ckA + data[i]) & 0xFF;
      ckB = (ckB + ckA) & 0xFF;
    }

    return data[checksumOffset] == ckA && data[checksumOffset + 1] == ckB;
  }

  // -------------------------------------------------------------------------
  // Binary helpers (little-endian)
  // -------------------------------------------------------------------------

  static int _getUint16(List<int> data, int offset) {
    final bytes = Uint8List.fromList(data.sublist(offset, offset + 2));
    return ByteData.sublistView(bytes).getUint16(0, Endian.little);
  }

  static int _getInt32(List<int> data, int offset) {
    final bytes = Uint8List.fromList(data.sublist(offset, offset + 4));
    return ByteData.sublistView(bytes).getInt32(0, Endian.little);
  }

  static int _getInt16(List<int> data, int offset) {
    final bytes = Uint8List.fromList(data.sublist(offset, offset + 2));
    return ByteData.sublistView(bytes).getInt16(0, Endian.little);
  }
}
