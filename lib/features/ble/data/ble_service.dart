import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/ble/domain/ble_device.dart';

// ---------------------------------------------------------------------------
// BLE Service — thin wrapper around flutter_reactive_ble
// ---------------------------------------------------------------------------

/// Low-level BLE service that wraps [FlutterReactiveBle].
///
/// Supports multiple simultaneous connections. All higher-level features
/// (RaceBox, OBD, etc.) should depend on this rather than using
/// flutter_reactive_ble directly.
class BleService {
  BleService({FlutterReactiveBle? ble}) : _ble = ble ?? FlutterReactiveBle();

  final FlutterReactiveBle _ble;

  /// Active connection subscriptions keyed by device ID.
  final _connectionSubscriptions = <String, StreamSubscription<ConnectionStateUpdate>>{};

  /// Scans for nearby BLE devices and emits an updated list as devices are
  /// discovered.
  ///
  /// Optionally filter by [withServices] UUIDs. The scan automatically stops
  /// after [timeout] (default 10 seconds).
  Stream<List<BleDevice>> scanForDevices({
    List<Uuid>? withServices,
    Duration timeout = const Duration(seconds: 10),
  }) {
    final discovered = <String, BleDevice>{};
    final controller = StreamController<List<BleDevice>>();

    final scanSubscription = _ble
        .scanForDevices(
          withServices: withServices ?? [],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            if (device.name.isNotEmpty) {
              discovered[device.id] = BleDevice(
                id: device.id,
                name: device.name,
                rssi: device.rssi,
                serviceUuids: device.serviceUuids
                    .map((uuid) => uuid.toString())
                    .toList(),
              );
              controller.add(discovered.values.toList());
            }
          },
          onError: (Object error) {
            controller.addError(error);
          },
        );

    // Auto-stop scan after timeout.
    final timer = Timer(timeout, () {
      scanSubscription.cancel();
      controller.close();
    });

    controller.onCancel = () {
      timer.cancel();
      scanSubscription.cancel();
    };

    return controller.stream;
  }

  /// Connects to a BLE device and emits [ConnectionStateUpdate]s.
  ///
  /// Multiple devices can be connected simultaneously — each connection is
  /// tracked independently by [deviceId].
  Stream<ConnectionStateUpdate> connectToDevice(String deviceId) {
    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    );
  }

  /// Subscribes to notifications on the given BLE [characteristic].
  Stream<List<int>> subscribeToCharacteristic(
    QualifiedCharacteristic characteristic,
  ) {
    return _ble.subscribeToCharacteristic(characteristic);
  }

  /// Writes data to a BLE characteristic.
  Future<void> writeCharacteristic(
    QualifiedCharacteristic characteristic,
    List<int> data,
  ) async {
    await _ble.writeCharacteristicWithoutResponse(
      characteristic,
      value: data,
    );
  }

  /// Disconnects a specific device by cancelling its connection subscription.
  void disconnect(String deviceId) {
    _connectionSubscriptions[deviceId]?.cancel();
    _connectionSubscriptions.remove(deviceId);
  }

  /// Tracks a connection subscription for cleanup.
  void trackConnection(String deviceId, StreamSubscription<ConnectionStateUpdate> sub) {
    // Cancel any existing subscription for this device first.
    _connectionSubscriptions[deviceId]?.cancel();
    _connectionSubscriptions[deviceId] = sub;
  }

  /// Clears any BLE connections from a previous app instance (e.g. hot restart).
  ///
  /// flutter_reactive_ble maintains native connections that survive Dart restarts.
  /// Call this on app startup to ensure a clean state.
  void clearStaleConnections() {
    for (final sub in _connectionSubscriptions.values) {
      sub.cancel();
    }
    _connectionSubscriptions.clear();
  }

  /// Disposes all resources.
  void dispose() {
    for (final sub in _connectionSubscriptions.values) {
      sub.cancel();
    }
    _connectionSubscriptions.clear();
  }
}

// ---------------------------------------------------------------------------
// Multi-Connection State Manager
// ---------------------------------------------------------------------------

/// Tracks the BLE connection state of multiple devices simultaneously.
///
/// State is a map of device ID → [BleConnectionState].
class BleConnectionManager extends StateNotifier<Map<String, BleConnectionState>> {
  BleConnectionManager(this._bleService) : super({});

  final BleService _bleService;
  final _subscriptions = <String, StreamSubscription<ConnectionStateUpdate>>{};

  /// Returns the connection state for a specific device, or disconnected.
  BleConnectionState stateFor(String deviceId) {
    return state[deviceId] ?? BleConnectionState.disconnected;
  }

  /// Whether any device is currently connected.
  bool get hasAnyConnection =>
      state.values.any((s) => s == BleConnectionState.connected);

  /// List of currently connected device IDs.
  List<String> get connectedDeviceIds => state.entries
      .where((e) => e.value == BleConnectionState.connected)
      .map((e) => e.key)
      .toList();

  /// Attempts to connect to the device with [deviceId].
  void connect(String deviceId) {
    state = {...state, deviceId: BleConnectionState.connecting};

    _subscriptions[deviceId]?.cancel();
    final sub = _bleService.connectToDevice(deviceId).listen(
      (update) {
        switch (update.connectionState) {
          case DeviceConnectionState.connecting:
            state = {...state, deviceId: BleConnectionState.connecting};
          case DeviceConnectionState.connected:
            state = {...state, deviceId: BleConnectionState.connected};
          case DeviceConnectionState.disconnecting:
          case DeviceConnectionState.disconnected:
            state = {...state, deviceId: BleConnectionState.disconnected};
        }
      },
      onError: (Object error) {
        state = {...state, deviceId: BleConnectionState.error};
      },
    );
    _subscriptions[deviceId] = sub;
    _bleService.trackConnection(deviceId, sub);
  }

  /// Disconnects a specific device.
  void disconnect(String deviceId) {
    _subscriptions[deviceId]?.cancel();
    _subscriptions.remove(deviceId);
    _bleService.disconnect(deviceId);
    state = {...state, deviceId: BleConnectionState.disconnected};
  }

  /// Disconnects all devices.
  void disconnectAll() {
    for (final deviceId in _subscriptions.keys.toList()) {
      disconnect(deviceId);
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

/// Provides the singleton [BleService] instance.
final bleServiceProvider = Provider<BleService>((ref) {
  final service = BleService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Scans for BLE devices and emits an updating list.
///
/// Auto-disposes when no longer listened to, which cancels the scan.
final bleScanProvider = StreamProvider.autoDispose<List<BleDevice>>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.scanForDevices(
    timeout: const Duration(seconds: 15),
  );
});

/// Manages BLE connections for multiple devices simultaneously.
///
/// State is a `Map<String, BleConnectionState>` keyed by device ID.
final bleConnectionManagerProvider =
    StateNotifierProvider<BleConnectionManager, Map<String, BleConnectionState>>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return BleConnectionManager(bleService);
});

/// Convenience provider: connection state for a single device.
///
/// Usage: `ref.watch(bleDeviceStateProvider('device-id'))`
final bleDeviceStateProvider = Provider.family<BleConnectionState, String>((ref, deviceId) {
  final connections = ref.watch(bleConnectionManagerProvider);
  return connections[deviceId] ?? BleConnectionState.disconnected;
});
