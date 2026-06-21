import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:race_coach/features/racebox/domain/racebox_data.dart';

/// Protocol parser for RaceBox Mini GPS devices.
///
/// The RaceBox Mini communicates over BLE using the Nordic UART Service (NUS).
/// It sends binary packets containing GPS and IMU telemetry data.
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
  // Packet constants
  // -------------------------------------------------------------------------

  /// Two-byte sync/header that starts every RaceBox packet.
  static const int headerByte1 = 0x24; // '$'
  static const int headerByte2 = 0x24; // '$'

  /// Message type for GPS telemetry data.
  static const int msgTypeGpsData = 0x01;

  /// Minimum valid packet length for a GPS data message (header + payload).
  static const int minGpsPacketLength = 37;

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

  /// Returns `true` if [data] looks like a valid RaceBox GPS data packet.
  static bool isValidPacket(List<int> data) {
    if (data.length < minGpsPacketLength) return false;
    if (data[0] != headerByte1 || data[1] != headerByte2) return false;
    if (data[2] != msgTypeGpsData) return false;

    // Verify payload length field matches actual data
    final payloadLength = _getUint16(data, 3);
    // Payload starts at byte 5, so total = 5 (header) + payloadLength
    if (data.length < 5 + payloadLength) return false;

    return true;
  }

  // -------------------------------------------------------------------------
  // Packet parsing
  // -------------------------------------------------------------------------

  /// Parses a raw binary packet from the RaceBox Mini into [RaceBoxData].
  ///
  /// Returns `null` if the packet is invalid or not a GPS data message.
  ///
  /// **Packet structure (little-endian):**
  /// | Offset | Size | Field               | Unit / Notes              |
  /// |--------|------|---------------------|---------------------------|
  /// | 0–1    | 2    | Header/sync         | 0x24 0x24                 |
  /// | 2      | 1    | Message type        | 0x01 = GPS data           |
  /// | 3–4    | 2    | Payload length      | uint16                    |
  /// | 5–8    | 4    | Timestamp           | uint32, ms since epoch    |
  /// | 9–12   | 4    | Latitude            | int32, degrees × 1e7      |
  /// | 13–16  | 4    | Longitude           | int32, degrees × 1e7      |
  /// | 17–20  | 4    | Speed               | uint32, mm/s              |
  /// | 21–24  | 4    | Heading             | uint32, degrees × 1e5     |
  /// | 25–28  | 4    | Altitude            | int32, mm                 |
  /// | 29     | 1    | Satellites          | uint8                     |
  /// | 30     | 1    | HDOP                | uint8, × 0.1              |
  /// | 31–32  | 2    | G-force X           | int16, milli-g            |
  /// | 33–34  | 2    | G-force Y           | int16, milli-g            |
  /// | 35–36  | 2    | G-force Z           | int16, milli-g            |
  static RaceBoxData? parsePacket(List<int> data) {
    if (!isValidPacket(data)) return null;

    try {
      // Timestamp — uint32, milliseconds since epoch
      final timestampMs = _getUint32(data, 5);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        timestampMs,
        isUtc: true,
      );

      // Latitude — int32, degrees × 1e7
      final latRaw = _getInt32(data, 9);
      final latitude = latRaw / 1e7;

      // Longitude — int32, degrees × 1e7
      final lonRaw = _getInt32(data, 13);
      final longitude = lonRaw / 1e7;

      // Speed — uint32, mm/s → km/h
      final speedMmPerS = _getUint32(data, 17);
      final speedKmh = (speedMmPerS / 1000.0) * 3.6; // m/s → km/h

      // Heading — uint32, degrees × 1e5
      final headingRaw = _getUint32(data, 21);
      final headingDegrees = headingRaw / 1e5;

      // Altitude — int32, mm → m
      final altRaw = _getInt32(data, 25);
      final altitudeMeters = altRaw / 1000.0;

      // Satellites — uint8
      final satellites = data[29];

      // HDOP — uint8, × 0.1
      final hdop = data[30] * 0.1;

      // G-forces — int16, milli-g → g
      final gForceX = _getInt16(data, 31) / 1000.0;
      final gForceY = _getInt16(data, 33) / 1000.0;
      final gForceZ = _getInt16(data, 35) / 1000.0;

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
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Binary helpers (little-endian)
  // -------------------------------------------------------------------------

  static int _getUint16(List<int> data, int offset) {
    final bytes = Uint8List.fromList(data.sublist(offset, offset + 2));
    return ByteData.sublistView(bytes).getUint16(0, Endian.little);
  }

  static int _getUint32(List<int> data, int offset) {
    final bytes = Uint8List.fromList(data.sublist(offset, offset + 4));
    return ByteData.sublistView(bytes).getUint32(0, Endian.little);
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
