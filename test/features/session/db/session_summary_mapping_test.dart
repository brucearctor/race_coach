import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as ts;

import 'package:race_coach/features/session/data/db/race_coach_db.dart';
import 'package:race_coach/features/session/data/db/session_dao.dart';
import 'package:race_coach/features/session/data/session_storage.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart' as proto;

/// Tests the full DB → SessionSummary mapping path.
///
/// Group 1 verifies raw DB storage (what the DAO writes).
/// Group 2 verifies the _summaryFromEntry normalization by driving the
/// public sessionStreamProvider with a ProviderContainer override.
void main() {
  late RaceCoachDb db;
  late SessionDao dao;

  setUp(() {
    db = RaceCoachDb.forTesting(NativeDatabase.memory());
    dao = SessionDao(db);
  });

  tearDown(() => db.close());

  // ── Helpers ──────────────────────────────────────────────────────

  ts.Timestamp tsFrom(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    return ts.Timestamp(
      seconds: Int64(ms ~/ 1000),
      nanos: (ms % 1000) * 1000000,
    );
  }

  proto.Session makeSession({
    required String id,
    String trackName = 'Thunderhill East',
    List<proto.Lap>? laps,
  }) {
    final session = proto.Session()
      ..sessionId = id
      ..trackName = trackName
      ..startTime = tsFrom(DateTime(2026, 6, 28));
    if (laps != null) session.laps.addAll(laps);
    return session;
  }

  proto.Lap makeLap({required int number, required double timeSecs}) {
    return proto.Lap()
      ..lapNumber = number
      ..lapTimeSeconds = timeSecs;
  }

  /// Create a ProviderContainer that overrides the DAO and DB providers
  /// to use our in-memory test database.
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        sessionDaoProvider.overrideWithValue(dao),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // ── Group 1: Raw DB storage ────────────────────────────────────

  group('DB raw storage', () {
    test('empty driver/vehicle strings stored as null in DB', () async {
      final meta = proto.SessionMeta()
        ..driverName = ''
        ..vehicle = (proto.Vehicle()..name = '');

      await dao.indexSession(makeSession(id: 'empty-strings'), meta: meta);

      final entries = await dao.watchAllSessions().first;
      expect(entries, hasLength(1));

      final entry = entries.first;
      expect(
        entry.driverName,
        isNull,
        reason: 'Empty driver name should be null in DB',
      );
      expect(
        entry.vehicleName,
        isNull,
        reason: 'Empty vehicle name should be null in DB',
      );
    });

    test('unspecified enum values stored as int 0 in DB', () async {
      final meta = proto.SessionMeta()
        ..sessionType = proto.SessionType.SESSION_TYPE_UNSPECIFIED
        ..conditions = (proto.Conditions()
          ..surface = proto.SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED);

      await dao.indexSession(makeSession(id: 'unspec-enums'), meta: meta);

      final entries = await dao.watchAllSessions().first;
      final entry = entries.first;

      expect(entry.sessionType, equals(0));
      expect(entry.surface, equals(0));
    });

    test('valid metadata stored correctly', () async {
      final meta = proto.SessionMeta()
        ..driverName = 'Bruce'
        ..vehicle = (proto.Vehicle()..name = 'Miata')
        ..sessionType = proto.SessionType.SESSION_TYPE_PRACTICE
        ..conditions = (proto.Conditions()
          ..surface = proto.SurfaceCondition.SURFACE_CONDITION_DRY)
        ..notes = 'Fast session';

      await dao.indexSession(
        makeSession(
          id: 'valid-meta',
          laps: [makeLap(number: 1, timeSecs: 95.5)],
        ),
        meta: meta,
      );

      final entries = await dao.watchAllSessions().first;
      final entry = entries.first;

      expect(entry.driverName, equals('Bruce'));
      expect(entry.vehicleName, equals('Miata'));
      expect(
        entry.sessionType,
        equals(proto.SessionType.SESSION_TYPE_PRACTICE.value),
      );
      expect(
        entry.surface,
        equals(proto.SurfaceCondition.SURFACE_CONDITION_DRY.value),
      );
      expect(entry.notes, equals('Fast session'));
      expect(entry.lapCount, equals(1));
      expect(entry.bestLapMs, equals(95500));
    });

    test('null meta produces null metadata fields', () async {
      await dao.indexSession(makeSession(id: 'no-meta'));

      final entries = await dao.watchAllSessions().first;
      final entry = entries.first;

      expect(entry.driverName, isNull);
      expect(entry.vehicleName, isNull);
      expect(entry.sessionType, isNull);
      expect(entry.surface, isNull);
      expect(entry.notes, isNull);
    });

    test(
      'session with only partial laps has lapCount 0 and null bestLap',
      () async {
        await dao.indexSession(
          makeSession(
            id: 'partial-only',
            laps: [
              makeLap(number: 1, timeSecs: 0),
              makeLap(number: 2, timeSecs: -1),
            ],
          ),
        );

        final entries = await dao.watchAllSessions().first;
        final entry = entries.first;

        expect(entry.lapCount, equals(0));
        expect(entry.bestLapMs, isNull);
      },
    );
  });

  // ── Group 2: End-to-end through _summaryFromEntry ──────────────

  group('sessionStreamProvider mapping (exercises _summaryFromEntry)', () {
    test('normalizes empty strings to null in SessionSummary', () async {
      final meta = proto.SessionMeta()
        ..driverName = ''
        ..vehicle = (proto.Vehicle()..name = '');

      await dao.indexSession(makeSession(id: 'e2e-empty'), meta: meta);

      final container = makeContainer();
      final summaries = await container.read(sessionStreamProvider.future);
      final summary = summaries.single;

      expect(
        summary.driverName,
        isNull,
        reason: '_summaryFromEntry should normalize empty string to null',
      );
      expect(
        summary.vehicleName,
        isNull,
        reason: '_summaryFromEntry should normalize empty string to null',
      );
    });

    test('normalizes unspecified enums to null in SessionSummary', () async {
      final meta = proto.SessionMeta()
        ..sessionType = proto.SessionType.SESSION_TYPE_UNSPECIFIED
        ..conditions = (proto.Conditions()
          ..surface = proto.SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED);

      await dao.indexSession(makeSession(id: 'e2e-unspec'), meta: meta);

      final container = makeContainer();
      final summaries = await container.read(sessionStreamProvider.future);
      final summary = summaries.single;

      expect(
        summary.sessionType,
        isNull,
        reason: '_summaryFromEntry should normalize UNSPECIFIED to null',
      );
      expect(
        summary.surface,
        isNull,
        reason: '_summaryFromEntry should normalize UNSPECIFIED to null',
      );
    });

    test('preserves valid metadata in SessionSummary', () async {
      final meta = proto.SessionMeta()
        ..driverName = 'Bruce'
        ..vehicle = (proto.Vehicle()..name = 'Miata')
        ..sessionType = proto.SessionType.SESSION_TYPE_PRACTICE
        ..conditions = (proto.Conditions()
          ..surface = proto.SurfaceCondition.SURFACE_CONDITION_DRY);

      await dao.indexSession(
        makeSession(
          id: 'e2e-valid',
          laps: [makeLap(number: 1, timeSecs: 95.5)],
        ),
        meta: meta,
      );

      final container = makeContainer();
      final summaries = await container.read(sessionStreamProvider.future);
      final summary = summaries.single;

      expect(summary.driverName, equals('Bruce'));
      expect(summary.vehicleName, equals('Miata'));
      expect(
        summary.sessionType,
        equals(proto.SessionType.SESSION_TYPE_PRACTICE),
      );
      expect(
        summary.surface,
        equals(proto.SurfaceCondition.SURFACE_CONDITION_DRY),
      );
      expect(summary.lapCount, equals(1));
      expect(summary.bestLap, equals(const Duration(milliseconds: 95500)));
    });

    test('null meta → all metadata fields null in SessionSummary', () async {
      await dao.indexSession(makeSession(id: 'e2e-nometa'));

      final container = makeContainer();
      final summaries = await container.read(sessionStreamProvider.future);
      final summary = summaries.single;

      expect(summary.driverName, isNull);
      expect(summary.vehicleName, isNull);
      expect(summary.sessionType, isNull);
      expect(summary.surface, isNull);
      expect(summary.bestLap, isNull);
    });

    test('partial-only laps → lapCount 0, bestLap null', () async {
      await dao.indexSession(
        makeSession(
          id: 'e2e-partial',
          laps: [
            makeLap(number: 1, timeSecs: 0),
            makeLap(number: 2, timeSecs: -1),
          ],
        ),
      );

      final container = makeContainer();
      final summaries = await container.read(sessionStreamProvider.future);
      final summary = summaries.single;

      expect(summary.lapCount, equals(0));
      expect(summary.bestLap, isNull);
    });
  });
}
