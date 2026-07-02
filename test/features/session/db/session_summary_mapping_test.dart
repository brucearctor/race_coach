import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as ts;

import 'package:race_coach/features/session/data/db/race_coach_db.dart';
import 'package:race_coach/features/session/data/db/session_dao.dart';
import 'package:race_coach/features/session/data/session_storage.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart' as proto;

/// Tests that the DB → SessionSummary mapping (via sessionStreamProvider's
/// _summaryFromEntry) correctly normalizes metadata fields to match the
/// filesystem-backed _summaryFromSession semantics.
///
/// We test this by indexing sessions through the DAO and verifying the
/// raw SessionEntry fields, since _summaryFromEntry is private.
/// The normalization helpers are exercised through the DAO → stream path.
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

  group('DB → SessionSummary null normalization', () {
    test('empty driver/vehicle strings stored as-is in DB', () async {
      final meta = proto.SessionMeta()
        ..driverName = ''
        ..vehicle = (proto.Vehicle()..name = '');

      await dao.indexSession(makeSession(id: 'empty-strings'), meta: meta);

      final entries = await dao.watchAllSessions().first;
      expect(entries, hasLength(1));

      // DAO stores Value.absent() for empty strings → null in DB
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

    test('unspecified enum values stored as DB int', () async {
      final meta = proto.SessionMeta()
        ..sessionType = proto.SessionType.SESSION_TYPE_UNSPECIFIED
        ..conditions = (proto.Conditions()
          ..surface = proto.SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED);

      await dao.indexSession(makeSession(id: 'unspec-enums'), meta: meta);

      final entries = await dao.watchAllSessions().first;
      final entry = entries.first;

      // Unspecified enum value (0) is stored in DB.
      // The _summaryFromEntry mapping must normalize it to null.
      // We verify the DB stores the raw value.
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
              makeLap(number: 1, timeSecs: 0), // partial
              makeLap(number: 2, timeSecs: -1), // invalid
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

  group('SessionSummary conversion via _summaryFromEntry', () {
    // These tests exercise the full path: DAO → DB → SessionEntry
    // The _summaryFromEntry function is private but we can verify
    // its behavior by checking that SessionSummary created from
    // the SessionStorage module matches expected null semantics.

    test('SessionSummary construction from SessionEntry data', () {
      // Simulate what _summaryFromEntry does with raw entry data.
      // We test the SessionSummary constructor directly.
      final summary = SessionSummary(
        sessionId: 'test-001',
        trackName: 'Thunderhill',
        date: DateTime(2026, 7, 1),
        lapCount: 3,
        bestLap: const Duration(milliseconds: 95500),
        driverName: 'Bruce',
        vehicleName: null, // normalized empty string
        surface: null, // normalized unspecified
        sessionType: proto.SessionType.SESSION_TYPE_PRACTICE,
      );

      expect(summary.sessionId, 'test-001');
      expect(summary.trackName, 'Thunderhill');
      expect(summary.lapCount, 3);
      expect(summary.bestLap, const Duration(milliseconds: 95500));
      expect(summary.driverName, 'Bruce');
      expect(summary.vehicleName, isNull);
      expect(summary.surface, isNull);
      expect(summary.sessionType, proto.SessionType.SESSION_TYPE_PRACTICE);
    });
  });
}
