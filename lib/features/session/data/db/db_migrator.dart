import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:race_coach/features/session/data/db/race_coach_db.dart';
import 'package:race_coach/features/session/data/db/session_dao.dart';
import 'package:race_coach/features/session/data/session_storage.dart';
import 'package:race_coach/features/session/data/session_meta_storage.dart';

/// Migrates existing protobuf session files into the Drift DB index.
///
/// Called on app startup. Compares session count on disk vs DB. If they
/// differ, performs a full rebuild from disk. This is also the "nuclear
/// option" for recovering from any DB corruption.
class DbMigrator {
  DbMigrator({
    required this.db,
    required this.dao,
    required this.storage,
    required this.metaStorage,
  });

  final RaceCoachDb db;
  final SessionDao dao;
  final SessionStorage storage;
  final SessionMetaStorage metaStorage;

  /// Returns true if migration was performed.
  /// Returns false if DB is already in sync.
  Future<bool> migrateIfNeeded() async {
    final diskIds = await _diskSessionIds();
    final dbIds = await _dbSessionIds();

    if (diskIds.isEmpty && dbIds.isEmpty) {
      debugPrint('[DbMigrator] No sessions on disk or in DB');
      return false;
    }

    if (diskIds.length == dbIds.length && diskIds.difference(dbIds).isEmpty) {
      debugPrint('[DbMigrator] Index is in sync (${dbIds.length} sessions)');
      return false;
    }

    debugPrint(
      '[DbMigrator] Rebuilding index: '
      'DB has ${dbIds.length}, disk has ${diskIds.length}',
    );
    await rebuildIndex();
    return true;
  }

  /// Drop all DB rows and rescan the filesystem.
  ///
  /// Idempotent — safe to call multiple times.
  Future<void> rebuildIndex() async {
    // Clear existing data.
    await db.delete(db.lapIndex).go();
    await db.delete(db.sessionIndex).go();

    final appDir = await getApplicationDocumentsDirectory();
    final sessionsDir = Directory('${appDir.path}/sessions');
    if (!sessionsDir.existsSync()) {
      debugPrint('[DbMigrator] No sessions directory found');
      return;
    }

    final dirs = sessionsDir.listSync().whereType<Directory>().toList();

    var indexed = 0;
    var skipped = 0;

    for (final dir in dirs) {
      final sessionId = dir.path.split('/').last;
      try {
        final session = await storage.loadSession(sessionId);

        // Load metadata if available.
        final meta = await metaStorage.load(sessionId);

        await dao.indexSession(session, meta: meta);
        indexed++;
      } catch (e) {
        debugPrint('[DbMigrator] Skipping $sessionId: $e');
        skipped++;
      }
    }

    debugPrint('[DbMigrator] Indexed $indexed sessions, skipped $skipped');
  }

  /// Get session IDs from disk (directories containing session.pb).
  Future<Set<String>> _diskSessionIds() async {
    final appDir = await getApplicationDocumentsDirectory();
    final sessionsDir = Directory('${appDir.path}/sessions');
    if (!sessionsDir.existsSync()) return {};

    return sessionsDir
        .listSync()
        .whereType<Directory>()
        .where((d) => File('${d.path}/session.pb').existsSync())
        .map((d) => d.path.split('/').last)
        .toSet();
  }

  /// Get session IDs from the DB index.
  Future<Set<String>> _dbSessionIds() async {
    final sessions = await dao.watchAllSessions().first;
    return sessions.map((s) => s.id).toSet();
  }
}

/// Global migrator provider.
final dbMigratorProvider = Provider<DbMigrator>((ref) {
  return DbMigrator(
    db: ref.watch(dbProvider),
    dao: ref.watch(sessionDaoProvider),
    storage: ref.watch(sessionStorageProvider),
    metaStorage: ref.watch(sessionMetaStorageProvider),
  );
});
