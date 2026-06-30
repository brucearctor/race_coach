import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// =============================================================================
// Reference Lap Preferences — persists which lap to use as reference per track
// =============================================================================

/// Persisted selection of which lap to use as reference for a given track.
class ReferenceLapSelection {
  const ReferenceLapSelection({
    required this.sessionId,
    required this.lapNumber,
  });

  final String sessionId;
  final int lapNumber;

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'lapNumber': lapNumber,
      };

  factory ReferenceLapSelection.fromJson(Map<String, dynamic> json) {
    return ReferenceLapSelection(
      sessionId: json['sessionId'] as String,
      lapNumber: json['lapNumber'] as int,
    );
  }
}

/// Stores reference lap selections per track on the local filesystem.
///
/// Stored as `<app_documents>/reference_laps.json` — a flat map of
/// track name → selection.
class ReferenceLapPrefs {
  Map<String, ReferenceLapSelection>? _cache;

  /// Get the persisted reference lap selection for a track.
  Future<ReferenceLapSelection?> getSelection(String trackName) async {
    final prefs = await _load();
    return prefs[_normalizeTrackName(trackName)];
  }

  /// Save a reference lap selection for a track.
  Future<void> saveSelection(
    String trackName,
    ReferenceLapSelection selection,
  ) async {
    final prefs = Map<String, ReferenceLapSelection>.of(await _load());
    prefs[_normalizeTrackName(trackName)] = selection;
    await _save(prefs);
  }

  /// Clear the reference lap selection for a track.
  Future<void> clearSelection(String trackName) async {
    final prefs = Map<String, ReferenceLapSelection>.of(await _load());
    prefs.remove(_normalizeTrackName(trackName));
    await _save(prefs);
  }

  // ── Internal ──────────────────────────────────────────────────────────

  String _normalizeTrackName(String name) => name.toLowerCase().trim();

  Future<File> _prefsFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/reference_laps.json');
  }

  Future<Map<String, ReferenceLapSelection>> _load() async {
    if (_cache != null) return _cache!;

    final file = await _prefsFile();
    if (!file.existsSync()) {
      _cache = {};
      return _cache!;
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      _cache = json.map((key, value) => MapEntry(
            key,
            ReferenceLapSelection.fromJson(value as Map<String, dynamic>),
          ));
    } catch (e) {
      debugPrint('[ReferenceLapPrefs] Error reading prefs: $e');
      _cache = {};
    }

    return _cache!;
  }

  Future<void> _save(Map<String, ReferenceLapSelection> prefs) async {
    final file = await _prefsFile();
    final json = prefs.map((key, value) => MapEntry(key, value.toJson()));
    await file.writeAsString(jsonEncode(json));
    // Only update cache after successful write.
    _cache = prefs;
  }
}

// =============================================================================
// Riverpod provider
// =============================================================================

/// Singleton [ReferenceLapPrefs] instance.
final referenceLapPrefsProvider = Provider<ReferenceLapPrefs>((ref) {
  return ReferenceLapPrefs();
});
