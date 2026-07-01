import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'package:race_coach/generated/racecoach/v1/session.pb.dart';

// =============================================================================
// SessionMetaStorage — read/write meta.pb files
// =============================================================================

/// Manages reading and writing [SessionMeta] protobuf files.
///
/// Each session directory may contain a `meta.pb` file alongside the existing
/// `session.pb` and `raw_frames.pb` files. The meta file is small (~200 bytes)
/// and can be rewritten for post-session edits without touching telemetry data.
class SessionMetaStorage {
  /// Read metadata for a session.
  ///
  /// Returns `null` for old sessions recorded before metadata support was
  /// added (i.e. no `meta.pb` file exists).
  Future<SessionMeta?> load(String sessionId) async {
    final file = await _metaFile(sessionId);
    if (!file.existsSync()) return null;

    try {
      final bytes = await file.readAsBytes();
      return SessionMeta.fromBuffer(bytes);
    } catch (_) {
      // Corrupted file — treat as missing.
      return null;
    }
  }

  /// Write or overwrite metadata for a session.
  ///
  /// Sets `updated_at` to the current time automatically.
  Future<void> save(String sessionId, SessionMeta meta) async {
    meta.updatedAt = _timestampNow();
    final file = await _metaFile(sessionId);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(meta.writeToBuffer());
  }

  /// Check whether a meta.pb exists for the given session.
  Future<bool> exists(String sessionId) async {
    final file = await _metaFile(sessionId);
    return file.existsSync();
  }

  /// Delete meta.pb for a session (used when deleting a session).
  Future<void> delete(String sessionId) async {
    final file = await _metaFile(sessionId);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<File> _metaFile(String sessionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/sessions/$sessionId/meta.pb');
  }

  static Timestamp _timestampNow() {
    final now = DateTime.now();
    final ms = now.millisecondsSinceEpoch;
    return Timestamp(seconds: Int64(ms ~/ 1000), nanos: (ms % 1000) * 1000000);
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

/// Provides a singleton [SessionMetaStorage] instance.
final sessionMetaStorageProvider = Provider<SessionMetaStorage>((ref) {
  return SessionMetaStorage();
});
