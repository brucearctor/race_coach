import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'race_coach_db.g.dart';

/// Drift database for the session/lap index.
///
/// This is a queryable cache — protobuf files on disk are the source of truth.
/// The DB can be rebuilt from them at any time via [DbMigrator.rebuildIndex].
@DriftDatabase(include: {'tables.drift'})
class RaceCoachDb extends _$RaceCoachDb {
  /// Production constructor — opens the DB from the app documents directory.
  RaceCoachDb() : super(_openConnection());

  /// Test constructor — accepts an in-memory or custom executor.
  RaceCoachDb.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Future schema migrations go here.
      // Nuclear option: drop all tables, recreate, rebuild from protobuf.
    },
    beforeOpen: (details) async {
      // SQLite disables FK enforcement by default — enable it.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'race_coach.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}

/// Global database provider. Single instance for the app lifetime.
final dbProvider = Provider<RaceCoachDb>((ref) {
  final db = RaceCoachDb();
  ref.onDispose(() => db.close());
  return db;
});
