import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as ts;

import 'package:race_coach/features/session/data/db/race_coach_db.dart';
import 'package:race_coach/features/session/data/db/session_dao.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart' as proto;

void main() {
  late RaceCoachDb db;
  late SessionDao dao;

  setUp(() {
    db = RaceCoachDb.forTesting(NativeDatabase.memory());
    dao = SessionDao(db);
  });

  tearDown(() => db.close());

  // ── Test helpers ──────────────────────────────────────────────────

  ts.Timestamp _tsFromDateTime(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    return ts.Timestamp(
      seconds: Int64(ms ~/ 1000),
      nanos: (ms % 1000) * 1000000,
    );
  }

  proto.Session _makeSession({
    required String id,
    String trackName = 'Thunderhill East',
    List<proto.Lap>? laps,
    DateTime? startTime,
  }) {
    final session = proto.Session()
      ..sessionId = id
      ..trackName = trackName
      ..startTime = _tsFromDateTime(startTime ?? DateTime(2026, 6, 28));

    if (laps != null) {
      session.laps.addAll(laps);
    }

    return session;
  }

  proto.Lap _makeLap({required int number, required double timeSecs}) {
    return proto.Lap()
      ..lapNumber = number
      ..lapTimeSeconds = timeSecs;
  }

  proto.SessionMeta _makeMeta({
    String driverName = 'Bruce',
    String vehicleName = 'Miata',
    proto.SessionType sessionType = proto.SessionType.SESSION_TYPE_PRACTICE,
    proto.SurfaceCondition surface =
        proto.SurfaceCondition.SURFACE_CONDITION_DRY,
    String notes = '',
  }) {
    return proto.SessionMeta()
      ..driverName = driverName
      ..vehicle = (proto.Vehicle()..name = vehicleName)
      ..sessionType = sessionType
      ..conditions = (proto.Conditions()..surface = surface)
      ..notes = notes;
  }

  // ── Insert + Query ────────────────────────────────────────────────

  group('CRUD operations', () {
    test('indexSession creates session and lap rows', () async {
      final session = _makeSession(
        id: 'test-001',
        laps: [
          _makeLap(number: 1, timeSecs: 102.3),
          _makeLap(number: 2, timeSecs: 101.5),
          _makeLap(number: 3, timeSecs: 100.8),
        ],
      );
      final meta = _makeMeta();

      await dao.indexSession(session, meta: meta);

      // Verify session row.
      final sessions = await dao.watchAllSessions().first;
      expect(sessions, hasLength(1));
      expect(sessions[0].id, 'test-001');
      expect(sessions[0].trackName, 'Thunderhill East');
      expect(sessions[0].lapCount, 3);
      expect(sessions[0].bestLapMs, 100800); // 100.8s
      expect(sessions[0].driverName, 'Bruce');
      expect(sessions[0].vehicleName, 'Miata');

      // Verify lap rows.
      final laps = await dao.watchLaps('test-001').first;
      expect(laps, hasLength(3));
      expect(laps[0].lapTimeMs, 102300);
      expect(laps[1].lapTimeMs, 101500);
      expect(laps[2].lapTimeMs, 100800);
    });

    test('partial laps (lapTimeSeconds <= 0) are excluded', () async {
      final session = _makeSession(
        id: 'test-002',
        laps: [
          _makeLap(number: 1, timeSecs: 102.3),
          _makeLap(number: 2, timeSecs: 0), // partial
        ],
      );

      await dao.indexSession(session);

      final laps = await dao.watchLaps('test-002').first;
      expect(laps, hasLength(1));
    });

    test('indexSession without meta has null metadata fields', () async {
      final session = _makeSession(id: 'test-003');
      await dao.indexSession(session);

      final sessions = await dao.watchAllSessions().first;
      expect(sessions[0].driverName, isNull);
      expect(sessions[0].vehicleName, isNull);
    });

    test('updateMeta updates metadata fields', () async {
      final session = _makeSession(id: 'test-004');
      await dao.indexSession(session);

      await dao.updateMeta(
        'test-004',
        _makeMeta(driverName: 'Alice', vehicleName: 'Corvette'),
      );

      final sessions = await dao.watchAllSessions().first;
      expect(sessions[0].driverName, 'Alice');
      expect(sessions[0].vehicleName, 'Corvette');
    });

    test('markUploaded sets uploaded flag', () async {
      final session = _makeSession(id: 'test-005');
      await dao.indexSession(session);

      expect((await dao.watchAllSessions().first)[0].uploaded, 0);

      await dao.markUploaded('test-005');

      expect((await dao.watchAllSessions().first)[0].uploaded, 1);
    });

    test('deleteSession removes session and laps', () async {
      final session = _makeSession(
        id: 'test-006',
        laps: [_makeLap(number: 1, timeSecs: 100.0)],
      );
      await dao.indexSession(session);

      expect(await dao.sessionCount(), 1);

      await dao.deleteSession('test-006');

      expect(await dao.sessionCount(), 0);
      final laps = await dao.watchLaps('test-006').first;
      expect(laps, isEmpty);
    });
  });

  // ── Queries ───────────────────────────────────────────────────────

  group('query operations', () {
    setUp(() async {
      // Seed data: 2 tracks, 3 sessions.
      await dao.indexSession(
        _makeSession(
          id: 'th-001',
          trackName: 'Thunderhill East',
          startTime: DateTime(2026, 6, 10),
          laps: [
            _makeLap(number: 1, timeSecs: 102.0),
            _makeLap(number: 2, timeSecs: 101.0),
          ],
        ),
        meta: _makeMeta(driverName: 'Bruce'),
      );

      await dao.indexSession(
        _makeSession(
          id: 'th-002',
          trackName: 'Thunderhill East',
          startTime: DateTime(2026, 6, 28),
          laps: [
            _makeLap(number: 1, timeSecs: 100.5),
            _makeLap(number: 2, timeSecs: 99.8),
          ],
        ),
        meta: _makeMeta(driverName: 'Alice'),
      );

      await dao.indexSession(
        _makeSession(
          id: 'son-001',
          trackName: 'Sonoma Raceway',
          startTime: DateTime(2026, 6, 15),
          laps: [_makeLap(number: 1, timeSecs: 118.1)],
        ),
      );
    });

    test('watchAllSessions returns newest first', () async {
      final sessions = await dao.watchAllSessions().first;
      expect(sessions, hasLength(3));
      expect(sessions[0].id, 'th-002'); // Jun 28
      expect(sessions[1].id, 'son-001'); // Jun 15
      expect(sessions[2].id, 'th-001'); // Jun 10
    });

    test('watchByTrack filters correctly', () async {
      final sessions = await dao.watchByTrack('Thunderhill East').first;
      expect(sessions, hasLength(2));
      expect(sessions.every((s) => s.trackName == 'Thunderhill East'), isTrue);
    });

    test('personalBest returns fastest lap at track', () async {
      final best = await dao.personalBest('Thunderhill East');
      expect(best, 99800); // 99.8s
    });

    test('personalBest returns null for unknown track', () async {
      final best = await dao.personalBest('Unknown Track');
      expect(best, isNull);
    });

    test('distinctTracks returns sorted unique names', () async {
      final tracks = await dao.distinctTracks();
      expect(tracks, ['Sonoma Raceway', 'Thunderhill East']);
    });

    test('sessionCount returns total', () async {
      expect(await dao.sessionCount(), 3);
    });

    test('lapTimeTrend returns time-ordered data', () async {
      final trend = await dao.lapTimeTrend('Thunderhill East');
      expect(trend, hasLength(4)); // 2 laps × 2 sessions
      // First session (Jun 10) laps come first.
      expect(trend[0].lapTimeMs, 102000);
      expect(trend[1].lapTimeMs, 101000);
      // Second session (Jun 28) laps come second.
      expect(trend[2].lapTimeMs, 100500);
      expect(trend[3].lapTimeMs, 99800);
    });
  });

  // ── Reactive streams ──────────────────────────────────────────────

  group('reactive streams', () {
    test('watchAllSessions emits on insert', () async {
      final stream = dao.watchAllSessions();

      // Initial state: empty.
      expect(await stream.first, isEmpty);

      // Insert a session.
      await dao.indexSession(_makeSession(id: 'stream-001'));

      // Stream should emit updated list.
      final sessions = await stream.first;
      expect(sessions, hasLength(1));
    });
  });

  // ── Upsert behavior ──────────────────────────────────────────────

  group('idempotency', () {
    test('indexSession is idempotent (upsert)', () async {
      final session = _makeSession(
        id: 'upsert-001',
        laps: [_makeLap(number: 1, timeSecs: 102.0)],
      );

      // Index twice.
      await dao.indexSession(session);
      await dao.indexSession(session);

      expect(await dao.sessionCount(), 1);
      final laps = await dao.watchLaps('upsert-001').first;
      expect(laps, hasLength(1));
    });
  });
}
