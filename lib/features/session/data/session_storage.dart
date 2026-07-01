import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:race_coach/generated/racecoach/v1/session.pb.dart';

// =============================================================================
// SessionSummary — lightweight metadata for listing
// =============================================================================

/// A lightweight summary of a saved session, used for listing without loading
/// the full proto (which may contain many megabytes of telemetry data).
///
/// Metadata fields (driver, vehicle, surface, sessionType) are populated from
/// `meta.pb` if it exists. Old sessions without metadata will have these as
/// `null`.
class SessionSummary {
  const SessionSummary({
    required this.sessionId,
    required this.trackName,
    required this.date,
    required this.lapCount,
    this.bestLap,
    this.driverName,
    this.vehicleName,
    this.surface,
    this.sessionType,
  });

  final String sessionId;
  final String trackName;
  final DateTime date;
  final int lapCount;

  /// Best (fastest) lap time, or `null` if no completed laps.
  final Duration? bestLap;

  /// Driver name from session metadata, or `null` for old sessions.
  final String? driverName;

  /// Vehicle name from session metadata, or `null` for old sessions.
  final String? vehicleName;

  /// Track surface condition, or `null` for old sessions.
  final SurfaceCondition? surface;

  /// Session type (practice/qualifying/race/test), or `null` for old sessions.
  final SessionType? sessionType;

  @override
  String toString() =>
      'SessionSummary($sessionId, $trackName, laps: $lapCount, '
      'best: ${bestLap?.inMilliseconds}ms, driver: $driverName)';
}

// =============================================================================
// SessionStorage — reads and manages saved session files
// =============================================================================

/// Manages reading, listing, and deleting saved session data from the local
/// filesystem.
///
/// Session files are stored under:
///   `<app_documents>/sessions/<session_id>/`
///     session.pb          — full Session proto
///     raw_frames.pb       — length-delimited TelemetryFrame stream
class SessionStorage {
  /// List all saved sessions by scanning the sessions directory.
  ///
  /// Each session directory is read lazily: we deserialise only the Session
  /// proto's metadata fields (track name, timestamps, laps) to build a
  /// [SessionSummary].
  Future<List<SessionSummary>> listSessions() async {
    final sessionsDir = await _sessionsRoot();
    if (!sessionsDir.existsSync()) return [];

    final summaries = <SessionSummary>[];

    await for (final entity in sessionsDir.list()) {
      if (entity is! Directory) continue;

      final sessionId = entity.path.split('/').last;
      final sessionFile = File('${entity.path}/session.pb');
      if (!sessionFile.existsSync()) continue;

      try {
        final bytes = await sessionFile.readAsBytes();
        final session = Session.fromBuffer(bytes);

        // Read metadata from meta.pb if it exists.
        final metaFile = File('${entity.path}/meta.pb');
        SessionMeta? meta;
        if (metaFile.existsSync()) {
          try {
            meta = SessionMeta.fromBuffer(await metaFile.readAsBytes());
          } catch (_) {
            // Corrupted meta — ignore, summary still works without it.
          }
        }

        summaries.add(_summaryFromSession(sessionId, session, meta: meta));
      } catch (_) {
        // Skip corrupted or unreadable files.
        continue;
      }
    }

    // Sort newest first.
    summaries.sort((a, b) => b.date.compareTo(a.date));
    return summaries;
  }

  /// Load the full [Session] proto for the given [sessionId].
  ///
  /// Throws a [FileSystemException] if the session directory or file does not
  /// exist.
  Future<Session> loadSession(String sessionId) async {
    final file = await _sessionFile(sessionId);
    final bytes = await file.readAsBytes();
    return Session.fromBuffer(bytes);
  }

  /// Delete a session directory and all its contents.
  Future<void> deleteSession(String sessionId) async {
    final dir = await _sessionDirectory(sessionId);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Root directory for all sessions.
  Future<Directory> _sessionsRoot() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/sessions');
  }

  /// Directory for a specific session.
  Future<Directory> _sessionDirectory(String sessionId) async {
    final root = await _sessionsRoot();
    return Directory('${root.path}/$sessionId');
  }

  /// The `session.pb` file for a given session.
  Future<File> _sessionFile(String sessionId) async {
    final dir = await _sessionDirectory(sessionId);
    return File('${dir.path}/session.pb');
  }

  /// Build a [SessionSummary] from a parsed [Session] proto and optional
  /// [SessionMeta].
  SessionSummary _summaryFromSession(
    String sessionId,
    Session session, {
    SessionMeta? meta,
  }) {
    // Derive the date from the proto start_time, falling back to parsing the
    // session id prefix (YYYY-MM-DD_...).
    DateTime date;
    if (session.hasStartTime()) {
      date = DateTime.fromMillisecondsSinceEpoch(
        session.startTime.seconds.toInt() * 1000 +
            session.startTime.nanos ~/ 1000000,
      );
    } else {
      // Best-effort parse from directory name.
      date = parseDateFromId(sessionId);
    }

    // Find the best (fastest) completed lap.
    Duration? bestLap;
    for (final lap in session.laps) {
      if (lap.lapTimeSeconds <= 0) continue; // Incomplete lap.
      final lapDuration = Duration(
        milliseconds: (lap.lapTimeSeconds * 1000).round(),
      );
      if (bestLap == null || lapDuration < bestLap) {
        bestLap = lapDuration;
      }
    }

    return SessionSummary(
      sessionId: sessionId,
      trackName: session.trackName,
      date: date,
      lapCount: session.laps.length,
      bestLap: bestLap,
      driverName:
          meta != null && meta.driverName.isNotEmpty ? meta.driverName : null,
      vehicleName:
          meta != null && meta.vehicle.name.isNotEmpty
              ? meta.vehicle.name
              : null,
      surface:
          meta != null &&
                  meta.conditions.surface != SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED
              ? meta.conditions.surface
              : null,
      sessionType:
          meta != null &&
                  meta.sessionType != SessionType.SESSION_TYPE_UNSPECIFIED
              ? meta.sessionType
              : null,
    );
  }

  /// Attempt to parse the date from a session id like
  /// `2026-06-22_thunderhill_east-bypass`.
  static DateTime parseDateFromId(String sessionId) {
    try {
      final datePart = sessionId.substring(0, 10); // "2026-06-22"
      return DateTime.parse(datePart);
    } catch (_) {
      return DateTime(2000); // Fallback for malformed ids.
    }
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

/// Provides a singleton [SessionStorage] instance.
final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage();
});

/// Provides the list of saved session summaries.
///
/// Invalidate this provider after recording stops or a session is deleted
/// to refresh the list.
final sessionListProvider = FutureProvider<List<SessionSummary>>((ref) {
  final storage = ref.watch(sessionStorageProvider);
  return storage.listSessions();
});
