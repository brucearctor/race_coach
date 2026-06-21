// BLE device model and connection state for the Race Coach app.

/// Represents the connection state of a BLE device.
enum BleConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Represents a discovered BLE device.
class BleDevice {
  final String id;
  final String name;
  final int rssi;
  final List<String> serviceUuids;

  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.serviceUuids = const [],
  });

  /// Whether this device appears to be a RaceBox device.
  bool get isRaceBox =>
      name.toLowerCase().contains('racebox') ||
      name.toLowerCase().contains('race box');

  /// Returns a human-readable RSSI signal quality description.
  String get signalQuality {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    if (rssi >= -80) return 'Poor';
    return 'Very Poor';
  }

  /// Returns a signal quality level from 0 (none) to 4 (excellent).
  int get signalLevel {
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    if (rssi >= -80) return 1;
    return 0;
  }

  BleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
    List<String>? serviceUuids,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      serviceUuids: serviceUuids ?? this.serviceUuids,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BleDevice && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BleDevice(id: $id, name: $name, rssi: $rssi, services: $serviceUuids)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rssi': rssi,
        'serviceUuids': serviceUuids,
      };

  factory BleDevice.fromJson(Map<String, dynamic> json) => BleDevice(
        id: json['id'] as String,
        name: json['name'] as String,
        rssi: json['rssi'] as int,
        serviceUuids: (json['serviceUuids'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}
