import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/session/data/session_storage.dart';

void main() {
  // ===========================================================================
  // SessionStorage.parseDateFromId
  // ===========================================================================

  group('SessionStorage.parseDateFromId', () {
    test('parses valid date from standard session id', () {
      final date =
          SessionStorage.parseDateFromId('2026-06-22_thunderhill_east-bypass');
      expect(date.year, 2026);
      expect(date.month, 6);
      expect(date.day, 22);
    });

    test('parses valid date from id with only the date prefix', () {
      final date = SessionStorage.parseDateFromId('2026-06-22');
      expect(date.year, 2026);
      expect(date.month, 6);
      expect(date.day, 22);
    });

    test('parses date from id with different track name', () {
      final date =
          SessionStorage.parseDateFromId('2025-12-31_laguna-seca_full');
      expect(date.year, 2025);
      expect(date.month, 12);
      expect(date.day, 31);
    });

    test('parses first day of year correctly', () {
      final date =
          SessionStorage.parseDateFromId('2026-01-01_some_track');
      expect(date.year, 2026);
      expect(date.month, 1);
      expect(date.day, 1);
    });

    test('malformed id returns DateTime(2000) fallback', () {
      final date = SessionStorage.parseDateFromId('not-a-valid-date-string');
      expect(date, DateTime(2000));
    });

    test('empty string returns DateTime(2000) fallback', () {
      final date = SessionStorage.parseDateFromId('');
      expect(date, DateTime(2000));
    });

    test('short string (< 10 chars) returns DateTime(2000) fallback', () {
      final date = SessionStorage.parseDateFromId('2026-06');
      expect(date, DateTime(2000));
    });

    test('single character returns DateTime(2000) fallback', () {
      final date = SessionStorage.parseDateFromId('X');
      expect(date, DateTime(2000));
    });

    test('date-like but invalid month parses leniently (Dart wraps months)', () {
      final date = SessionStorage.parseDateFromId('2026-13-01_track');
      // Dart's DateTime constructor wraps month 13 → January of next year.
      expect(date, DateTime(2027, 1, 1));
    });

    test('date-like but invalid day parses leniently (Dart wraps days)', () {
      final date = SessionStorage.parseDateFromId('2026-02-30_track');
      // Dart's DateTime constructor wraps Feb 30 → March 2.
      expect(date, DateTime(2026, 3, 2));
    });

    test('10 characters of garbage returns DateTime(2000) fallback', () {
      final date = SessionStorage.parseDateFromId('ABCDEFGHIJ');
      expect(date, DateTime(2000));
    });

    test('valid date prefix with unusual suffix still parses', () {
      final date = SessionStorage.parseDateFromId('2026-06-22!!!#@%');
      expect(date.year, 2026);
      expect(date.month, 6);
      expect(date.day, 22);
    });
  });

  // ===========================================================================
  // SessionSummary
  // ===========================================================================

  group('SessionSummary', () {
    test('constructor sets all required fields', () {
      final summary = SessionSummary(
        sessionId: '2026-06-22_thunderhill',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 22),
        lapCount: 15,
      );

      expect(summary.sessionId, '2026-06-22_thunderhill');
      expect(summary.trackName, 'Thunderhill East');
      expect(summary.date, DateTime(2026, 6, 22));
      expect(summary.lapCount, 15);
      expect(summary.bestLap, isNull);
    });

    test('constructor sets optional bestLap field', () {
      final summary = SessionSummary(
        sessionId: '2026-06-22_thunderhill',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 22),
        lapCount: 15,
        bestLap: const Duration(minutes: 1, seconds: 42, milliseconds: 300),
      );

      expect(summary.bestLap, isNotNull);
      expect(summary.bestLap!.inMilliseconds, 102300);
    });

    test('toString includes session id', () {
      final summary = SessionSummary(
        sessionId: '2026-06-22_thunderhill',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 22),
        lapCount: 15,
      );

      final str = summary.toString();
      expect(str, contains('2026-06-22_thunderhill'));
    });

    test('toString includes track name', () {
      final summary = SessionSummary(
        sessionId: '2026-06-22_thunderhill',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 22),
        lapCount: 15,
      );

      final str = summary.toString();
      expect(str, contains('Thunderhill East'));
    });

    test('toString includes lap count', () {
      final summary = SessionSummary(
        sessionId: '2026-06-22_thunderhill',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 22),
        lapCount: 15,
      );

      final str = summary.toString();
      expect(str, contains('15'));
    });

    test('toString includes best lap in milliseconds when present', () {
      final summary = SessionSummary(
        sessionId: '2026-06-22_thunderhill',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 22),
        lapCount: 10,
        bestLap: const Duration(seconds: 90),
      );

      final str = summary.toString();
      // best: 90000ms
      expect(str, contains('90000'));
    });

    test('toString includes "null" for best when no best lap', () {
      final summary = SessionSummary(
        sessionId: '2026-06-22_thunderhill',
        trackName: 'Thunderhill East',
        date: DateTime(2026, 6, 22),
        lapCount: 0,
      );

      final str = summary.toString();
      expect(str, contains('null'));
    });

    test('zero lap count is valid', () {
      final summary = SessionSummary(
        sessionId: 'test-session',
        trackName: 'Test Track',
        date: DateTime(2026, 1, 1),
        lapCount: 0,
      );

      expect(summary.lapCount, 0);
      expect(summary.bestLap, isNull);
    });
  });
}
