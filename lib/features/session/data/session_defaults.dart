import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:race_coach/generated/racecoach/v1/session.pb.dart';

// =============================================================================
// SessionDefaults — sticky defaults via SharedPreferences
// =============================================================================

/// Persists last-used session metadata values so the pre-session card can
/// pre-populate driver, vehicle, surface, etc. for the next recording.
///
/// Stored as proto3 JSON in SharedPreferences — uses the protobuf library's
/// built-in `toProto3Json()` / `mergeFromProto3Json()` for zero-effort
/// serialization.
class SessionDefaults {
  static const _key = 'session_defaults';
  static const _driversKey = 'session_drivers_history';
  static const _vehiclesKey = 'session_vehicles_history';

  /// Load last-used metadata values.
  ///
  /// Returns a default [SessionMeta] if no previous values exist.
  static Future<SessionMeta> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return SessionMeta();

    try {
      return SessionMeta()..mergeFromProto3Json(jsonDecode(json));
    } catch (_) {
      return SessionMeta();
    }
  }

  /// Save current metadata as defaults for next session.
  static Future<void> save(SessionMeta meta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(meta.toProto3Json()));

    // Also update history lists for driver/vehicle dropdowns.
    if (meta.driverName.isNotEmpty) {
      await _addToHistory(prefs, _driversKey, meta.driverName);
    }
    if (meta.vehicle.name.isNotEmpty) {
      await _addToHistory(prefs, _vehiclesKey, meta.vehicle.name);
    }
  }

  /// Get list of previously-used driver names (for dropdown).
  static Future<List<String>> driverHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_driversKey) ?? [];
  }

  /// Get list of previously-used vehicle names (for dropdown).
  static Future<List<String>> vehicleHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_vehiclesKey) ?? [];
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Add a value to a history list, keeping most recent first, max 10 entries.
  static Future<void> _addToHistory(
    SharedPreferences prefs,
    String key,
    String value,
  ) async {
    final history = prefs.getStringList(key) ?? [];
    history.remove(value); // Remove if already present.
    history.insert(0, value); // Add to front.
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    await prefs.setStringList(key, history);
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

/// Provides the last-used session defaults.
final sessionDefaultsProvider = FutureProvider<SessionMeta>((ref) {
  return SessionDefaults.load();
});
