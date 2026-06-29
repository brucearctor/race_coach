import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/ble/data/ble_service.dart';
import 'package:race_coach/features/racebox/data/racebox_protocol.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';

/// High-level service for connecting to a RaceBox Mini and streaming
/// parsed telemetry data.
///
/// Handles BLE connection, NUS characteristic subscription, packet
/// reassembly (in case data arrives across multiple BLE notifications),
/// and binary parsing via [RaceBoxProtocol].
class RaceBoxService {
  RaceBoxService(this._bleService);

  final BleService _bleService;

  var _dataController = StreamController<RaceBoxData>.broadcast();
  StreamSubscription<dynamic>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  /// Buffer for reassembling packets that may span multiple BLE notifications.
  final List<int> _packetBuffer = [];

  /// Counter for throttling debug output (prints every 25th frame).
  int _parseCount = 0;

  /// The device ID currently connected, or `null`.
  String? _connectedDeviceId;

  /// Stream of parsed [RaceBoxData] telemetry points.
  Stream<RaceBoxData> get dataStream => _dataController.stream;

  /// Whether we currently have an active connection.
  bool get isConnected => _connectedDeviceId != null;

  // -------------------------------------------------------------------------
  // Connection management
  // -------------------------------------------------------------------------

  /// Connects to a RaceBox Mini device and starts streaming data.
  ///
  /// Subscribes to the NUS TX characteristic for notifications and parses
  /// incoming binary packets into [RaceBoxData] on the [dataStream].
  Future<void> connect(String deviceId) async {
    // Disconnect any existing connection first.
    disconnect();

    // Re-create the stream controller if it was closed by dispose().
    if (_dataController.isClosed) {
      _dataController = StreamController<RaceBoxData>.broadcast();
    }

    _connectedDeviceId = deviceId;
    _packetBuffer.clear();

    // Listen for connection state changes.
    _connectionSubscription = _bleService
        .connectToDevice(deviceId)
        .listen(
          (update) {
            // Once connected, subscribe to the TX characteristic.
            if (update.connectionState == DeviceConnectionState.connected) {
              _subscribeToNotifications(deviceId);
            }
          },
          onError: (Object error) {
            _dataController.addError(error);
            disconnect();
          },
        );
  }

  /// Subscribes to the NUS TX characteristic for incoming data packets.
  void _subscribeToNotifications(String deviceId) {
    final txChar = RaceBoxProtocol.txCharacteristic(deviceId);

    _notificationSubscription = _bleService
        .subscribeToCharacteristic(txChar)
        .listen(
          _onDataReceived,
          onError: (Object error) {
            _dataController.addError(error);
          },
        );
  }

  /// Handles raw BLE notification data, buffering and parsing packets.
  void _onDataReceived(List<int> data) {
    _packetBuffer.addAll(data);

    // Try to extract complete packets from the buffer.
    while (_packetBuffer.length >= RaceBoxProtocol.minGpsPacketLength) {
      // Look for the sync header.
      final headerIndex = _findHeader(_packetBuffer);

      if (headerIndex < 0) {
        // No header found — discard everything.
        _packetBuffer.clear();
        break;
      }

      // Discard bytes before the header.
      if (headerIndex > 0) {
        _packetBuffer.removeRange(0, headerIndex);
      }

      // Need at least 6 bytes to read class, id, and payload length.
      if (_packetBuffer.length < 6) break;

      // UBX format: [0xB5, 0x62, class, id, lenLo, lenHi, ...payload..., ckA, ckB]
      // Read payload length (bytes 4-5, little-endian).
      final payloadLength = _packetBuffer[4] | (_packetBuffer[5] << 8);
      final totalPacketLength =
          6 +
          payloadLength +
          2; // header(2) + class(1) + id(1) + len(2) + payload + checksum(2)

      if (_packetBuffer.length < totalPacketLength) {
        break;
      }

      // Extract the complete packet.
      final packet = _packetBuffer.sublist(0, totalPacketLength);
      _packetBuffer.removeRange(0, totalPacketLength);

      // Parse it.
      final parsed = RaceBoxProtocol.parsePacket(packet);
      if (parsed != null) {
        _parseCount++;
        if (_parseCount % 25 == 1) {
          debugPrint(
            '[RaceBox] ✅ frame #$_parseCount: ${parsed.speedKmh.toStringAsFixed(1)} km/h, ${parsed.satellites} sats',
          );
        }
        _dataController.add(parsed);
      } else {
        debugPrint(
          '[RaceBox] ❌ Parse returned null for ${packet.length}-byte packet, type=0x${packet[2].toRadixString(16)}',
        );
      }
    }

    // Safety: prevent the buffer from growing unbounded if we get garbage.
    if (_packetBuffer.length > 1024) {
      debugPrint(
        '[RaceBox] Buffer overflow (${_packetBuffer.length} bytes), clearing',
      );
      _packetBuffer.clear();
    }
  }

  /// Finds the index of the two-byte sync header in [buffer].
  /// Returns -1 if not found.
  int _findHeader(List<int> buffer) {
    for (int i = 0; i < buffer.length - 1; i++) {
      if (buffer[i] == RaceBoxProtocol.headerByte1 &&
          buffer[i + 1] == RaceBoxProtocol.headerByte2) {
        return i;
      }
    }
    return -1;
  }

  /// Disconnects from the RaceBox device and cleans up resources.
  void disconnect() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;

    _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (_connectedDeviceId != null) {
      _bleService.disconnect(_connectedDeviceId!);
      _connectedDeviceId = null;
    }

    _packetBuffer.clear();
  }

  /// Disposes all internal resources. Call when the service is no longer needed.
  void dispose() {
    disconnect();
    _dataController.close();
  }
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

/// Tracks the device ID of the currently connected RaceBox, or `null`.
final connectedDeviceIdProvider = StateProvider<String?>((ref) => null);

/// Provides the singleton [RaceBoxService].
final raceBoxServiceProvider = Provider<RaceBoxService>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  final service = RaceBoxService(bleService);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Streams parsed [RaceBoxData] from the connected RaceBox device.
///
/// Use this to listen to the raw BLE data stream. For a synchronous
/// snapshot, see `raceBoxDataProvider` in `racebox_providers.dart`.
final raceBoxDataStreamProvider = StreamProvider<RaceBoxData>((ref) {
  final service = ref.watch(raceBoxServiceProvider);
  return service.dataStream;
});
