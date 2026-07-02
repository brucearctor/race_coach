import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/generated/racecoach/v1/session.pb.dart' as proto;
import 'package:race_coach/features/session/data/db/race_coach_db.dart';

/// Repository that bridges proto types ↔ Drift DB rows.
///
/// This is the **only** file that imports both proto types and Drift types.
/// Proto is truth, DB is derived.
class SessionDao {
  SessionDao(this._db);

  final RaceCoachDb _db;

  // ── Writes ──────────────────────────────────────────────────────────

  /// Index a session after recording stops.
  /// Call with the full [Session] proto and optional [SessionMeta].
  ///
  /// Wrapped in a transaction for atomicity — if any insert fails,
  /// no partial rows are left behind.
  Future<void> indexSession(
    proto.Session session, {
    proto.SessionMeta? meta,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final validLaps = session.laps.where((l) => l.lapTimeSeconds > 0).toList();
    final bestMs = _fastestLapMs(validLaps);

    await _db.transaction(() async {
      await _db
          .into(_db.sessionIndex)
          .insertOnConflictUpdate(
            SessionIndexCompanion(
              id: Value(session.sessionId),
              trackName: Value(session.trackName),
              dateMs: Value(
                session.hasStartTime()
                    ? session.startTime.toDateTime().millisecondsSinceEpoch
                    : now,
              ),
              lapCount: Value(validLaps.length),
              bestLapMs: Value(bestMs), // null clears stale value on re-index
              driverName: meta != null && meta.driverName.isNotEmpty
                  ? Value(meta.driverName)
                  : const Value.absent(),
              vehicleName: meta != null && meta.vehicle.name.isNotEmpty
                  ? Value(meta.vehicle.name)
                  : const Value.absent(),
              sessionType: meta != null
                  ? Value(meta.sessionType.value)
                  : const Value.absent(),
              surface: meta != null
                  ? Value(meta.conditions.surface.value)
                  : const Value.absent(),
              notes: meta != null && meta.notes.isNotEmpty
                  ? Value(meta.notes)
                  : const Value.absent(),
              createdAtMs: Value(now),
              updatedAtMs: Value(now),
            ),
          );

      // Delete existing laps then batch-insert (idempotent upsert).
      await (_db.delete(
        _db.lapIndex,
      )..where((l) => l.sessionId.equals(session.sessionId))).go();

      await _db.batch((batch) {
        batch.insertAll(
          _db.lapIndex,
          validLaps.map(
            (lap) => LapIndexCompanion.insert(
              sessionId: session.sessionId,
              lapNumber: lap.lapNumber,
              lapTimeMs: (lap.lapTimeSeconds * 1000).round(),
              sector1Ms: lap.sectorTimesSeconds.isNotEmpty
                  ? Value((lap.sectorTimesSeconds[0] * 1000).round())
                  : const Value.absent(),
              sector2Ms: lap.sectorTimesSeconds.length > 1
                  ? Value((lap.sectorTimesSeconds[1] * 1000).round())
                  : const Value.absent(),
              sector3Ms: lap.sectorTimesSeconds.length > 2
                  ? Value((lap.sectorTimesSeconds[2] * 1000).round())
                  : const Value.absent(),
            ),
          ),
        );
      });
    });
  }

  /// Update metadata fields (after editing driver, vehicle, notes, etc).
  Future<void> updateMeta(String sessionId, proto.SessionMeta meta) async {
    await (_db.update(
      _db.sessionIndex,
    )..where((s) => s.id.equals(sessionId))).write(
      SessionIndexCompanion(
        driverName: Value(meta.driverName),
        vehicleName: Value(meta.vehicle.name),
        sessionType: Value(meta.sessionType.value),
        surface: Value(meta.conditions.surface.value),
        notes: Value(meta.notes),
        updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Mark a session as uploaded to Firebase.
  Future<void> markUploaded(String sessionId) async {
    await (_db.update(
      _db.sessionIndex,
    )..where((s) => s.id.equals(sessionId))).write(
      SessionIndexCompanion(
        uploaded: const Value(1),
        updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Delete a session and its laps from the index.
  Future<void> deleteSession(String sessionId) async {
    await (_db.delete(
      _db.lapIndex,
    )..where((l) => l.sessionId.equals(sessionId))).go();
    await (_db.delete(
      _db.sessionIndex,
    )..where((s) => s.id.equals(sessionId))).go();
  }

  // ── Reads (reactive streams for Riverpod) ───────────────────────────

  /// Watch all sessions, newest first.
  Stream<List<SessionEntry>> watchAllSessions() => _db.allSessions().watch();

  /// Watch sessions filtered by track name.
  Stream<List<SessionEntry>> watchByTrack(String track) =>
      _db.sessionsByTrack(track).watch();

  /// Watch laps for a specific session.
  Stream<List<LapEntry>> watchLaps(String sessionId) =>
      _db.lapsForSession(sessionId).watch();

  /// Get the personal best lap time at a track (ms), or null.
  Future<int?> personalBest(String track) async {
    final result = await _db.personalBestAtTrack(track).getSingleOrNull();
    return result;
  }

  /// Get lap time trend data for a track (for charts).
  Future<List<LapTimeTrendResult>> lapTimeTrend(String track) =>
      _db.lapTimeTrend(track).get();

  /// Get distinct track names (for filter dropdown).
  Future<List<String>> distinctTracks() async {
    final rows = await _db.distinctTracks().get();
    return rows;
  }

  /// Get total session count in the index.
  Future<int> sessionCount() async {
    final result = await _db.sessionCount().getSingle();
    return result;
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Find fastest lap in a list of valid laps (ms), or null.
  static int? _fastestLapMs(List<proto.Lap> laps) {
    int? best;
    for (final lap in laps) {
      final ms = (lap.lapTimeSeconds * 1000).round();
      if (best == null || ms < best) best = ms;
    }
    return best;
  }
}

/// Global DAO provider.
final sessionDaoProvider = Provider<SessionDao>((ref) {
  return SessionDao(ref.watch(dbProvider));
});
