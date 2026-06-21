import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/logger.dart';

/// Riverpod provider for [PermissionService].
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Handles runtime permission requests for BLE and location.
///
/// Android requires Bluetooth Scan, Bluetooth Connect, and Location
/// for BLE operations. iOS requires Bluetooth.
class PermissionService {
  static const _tag = 'PermissionService';

  /// The set of permissions required for BLE functionality.
  static const List<Permission> _blePermissions = [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ];

  /// Requests all permissions needed for BLE scanning and connection.
  ///
  /// Returns `true` if every required permission was granted.
  Future<bool> requestBlePermissions() async {
    Log.info('Requesting BLE permissions…', tag: _tag);

    final statuses = await _blePermissions.request();

    final allGranted = statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );

    if (allGranted) {
      Log.info('All BLE permissions granted', tag: _tag);
    } else {
      final denied = statuses.entries
          .where((e) => !e.value.isGranted && !e.value.isLimited)
          .map((e) => e.key.toString())
          .join(', ');
      Log.warning('Permissions denied: $denied', tag: _tag);
    }

    return allGranted;
  }

  /// Checks whether all required permissions are currently granted
  /// **without** triggering a system prompt.
  Future<bool> checkAllPermissions() async {
    for (final permission in _blePermissions) {
      final status = await permission.status;
      if (!status.isGranted && !status.isLimited) {
        Log.debug(
          '${permission.toString()} not granted (status: $status)',
          tag: _tag,
        );
        return false;
      }
    }
    return true;
  }

  /// Opens the app settings page so the user can manually grant
  /// previously denied permissions.
  Future<bool> openSettings() async {
    Log.info('Opening app settings', tag: _tag);
    return openAppSettings();
  }
}
