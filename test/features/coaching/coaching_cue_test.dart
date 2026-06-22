import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/coaching/domain/coaching_cue.dart';

void main() {
  // ===========================================================================
  // CoachingCueType enum
  // ===========================================================================

  group('CoachingCueType', () {
    test('has all expected values', () {
      expect(
        CoachingCueType.values,
        containsAll([
          CoachingCueType.braking,
          CoachingCueType.throttle,
          CoachingCueType.line,
          CoachingCueType.speed,
          CoachingCueType.sectorTime,
          CoachingCueType.general,
          CoachingCueType.turnAnnouncement,
          CoachingCueType.lapTime,
        ]),
      );
    });

    test('has exactly 8 values', () {
      expect(CoachingCueType.values.length, 8);
    });
  });

  // ===========================================================================
  // CuePriority enum
  // ===========================================================================

  group('CuePriority', () {
    test('has exactly 4 values', () {
      expect(CuePriority.values.length, 4);
    });

    test('contains low, medium, high, critical', () {
      expect(
        CuePriority.values,
        containsAll([
          CuePriority.low,
          CuePriority.medium,
          CuePriority.high,
          CuePriority.critical,
        ]),
      );
    });

    test('ordinal order is low < medium < high < critical', () {
      expect(CuePriority.low.index, lessThan(CuePriority.medium.index));
      expect(CuePriority.medium.index, lessThan(CuePriority.high.index));
      expect(CuePriority.high.index, lessThan(CuePriority.critical.index));
    });
  });

  // ===========================================================================
  // CoachingCue construction
  // ===========================================================================

  group('CoachingCue constructor', () {
    test('sets all fields correctly', () {
      final timestamp = DateTime(2026, 6, 22, 14, 30);
      final cue = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake earlier',
        priority: CuePriority.high,
        timestamp: timestamp,
      );

      expect(cue.type, CoachingCueType.braking);
      expect(cue.message, 'Brake earlier');
      expect(cue.priority, CuePriority.high);
      expect(cue.timestamp, timestamp);
    });
  });

  // ===========================================================================
  // CoachingCue.copyWith
  // ===========================================================================

  group('CoachingCue.copyWith', () {
    late CoachingCue original;
    late DateTime originalTimestamp;

    setUp(() {
      originalTimestamp = DateTime(2026, 6, 22, 10, 0);
      original = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake later',
        priority: CuePriority.medium,
        timestamp: originalTimestamp,
      );
    });

    test('preserves unchanged fields when no arguments given', () {
      final copied = original.copyWith();

      expect(copied.type, original.type);
      expect(copied.message, original.message);
      expect(copied.priority, original.priority);
      expect(copied.timestamp, original.timestamp);
    });

    test('updates type when provided', () {
      final copied = original.copyWith(type: CoachingCueType.throttle);
      expect(copied.type, CoachingCueType.throttle);
      expect(copied.message, original.message);
    });

    test('updates message when provided', () {
      final copied = original.copyWith(message: 'More throttle');
      expect(copied.message, 'More throttle');
      expect(copied.type, original.type);
    });

    test('updates priority when provided', () {
      final copied = original.copyWith(priority: CuePriority.critical);
      expect(copied.priority, CuePriority.critical);
      expect(copied.message, original.message);
    });

    test('updates timestamp when provided', () {
      final newTimestamp = DateTime(2026, 6, 22, 12, 0);
      final copied = original.copyWith(timestamp: newTimestamp);
      expect(copied.timestamp, newTimestamp);
      expect(copied.type, original.type);
    });

    test('updates multiple fields at once', () {
      final copied = original.copyWith(
        type: CoachingCueType.speed,
        message: 'Carry more speed',
        priority: CuePriority.low,
      );
      expect(copied.type, CoachingCueType.speed);
      expect(copied.message, 'Carry more speed');
      expect(copied.priority, CuePriority.low);
      expect(copied.timestamp, original.timestamp);
    });
  });

  // ===========================================================================
  // CoachingCue.toString
  // ===========================================================================

  group('CoachingCue.toString', () {
    test('includes type, priority, and message', () {
      final cue = CoachingCue(
        type: CoachingCueType.line,
        message: 'Tighter apex',
        priority: CuePriority.high,
        timestamp: DateTime(2026, 6, 22),
      );

      final str = cue.toString();
      expect(str, contains('line'));
      expect(str, contains('high'));
      expect(str, contains('Tighter apex'));
    });

    test('matches expected format exactly', () {
      final cue = CoachingCue(
        type: CoachingCueType.general,
        message: 'Good job',
        priority: CuePriority.low,
        timestamp: DateTime(2026, 6, 22),
      );

      expect(
        cue.toString(),
        'CoachingCue(CoachingCueType.general, '
        'priority: CuePriority.low, '
        'message: "Good job")',
      );
    });
  });

  // ===========================================================================
  // CoachingCue equality
  // ===========================================================================

  group('CoachingCue equality', () {
    final timestamp = DateTime(2026, 6, 22, 14, 30);

    test('same fields → equal', () {
      final a = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      final b = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      expect(a, equals(b));
    });

    test('different message → not equal', () {
      final a = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      final b = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake harder!',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      expect(a, isNot(equals(b)));
    });

    test('different type → not equal', () {
      final a = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      final b = CoachingCue(
        type: CoachingCueType.throttle,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      expect(a, isNot(equals(b)));
    });

    test('different timestamp → not equal', () {
      final a = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: DateTime(2026, 6, 22, 14, 30),
      );
      final b = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: DateTime(2026, 6, 22, 14, 31),
      );
      expect(a, isNot(equals(b)));
    });

    test('different priority but same type/message/timestamp → equal '
        '(priority not in equality)', () {
      // Note: the equality implementation does NOT include priority,
      // only type, message, and timestamp.
      final a = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      final b = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Brake!',
        priority: CuePriority.low,
        timestamp: timestamp,
      );
      expect(a, equals(b));
    });

    test('identical reference → equal', () {
      final cue = CoachingCue(
        type: CoachingCueType.general,
        message: 'Test',
        priority: CuePriority.low,
        timestamp: timestamp,
      );
      expect(cue, equals(cue));
    });

    test('not equal to non-CoachingCue object', () {
      final cue = CoachingCue(
        type: CoachingCueType.general,
        message: 'Test',
        priority: CuePriority.low,
        timestamp: timestamp,
      );
      // ignore: unrelated_type_equality_checks
      expect(cue == 'not a cue', isFalse);
    });
  });

  // ===========================================================================
  // CoachingCue hashCode
  // ===========================================================================

  group('CoachingCue hashCode', () {
    test('equal objects have same hashCode', () {
      final timestamp = DateTime(2026, 6, 22, 14, 30);
      final a = CoachingCue(
        type: CoachingCueType.speed,
        message: 'Faster',
        priority: CuePriority.medium,
        timestamp: timestamp,
      );
      final b = CoachingCue(
        type: CoachingCueType.speed,
        message: 'Faster',
        priority: CuePriority.medium,
        timestamp: timestamp,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different objects typically have different hashCodes', () {
      final timestamp = DateTime(2026, 6, 22, 14, 30);
      final a = CoachingCue(
        type: CoachingCueType.speed,
        message: 'Faster',
        priority: CuePriority.medium,
        timestamp: timestamp,
      );
      final b = CoachingCue(
        type: CoachingCueType.braking,
        message: 'Slower',
        priority: CuePriority.high,
        timestamp: timestamp,
      );
      // Not guaranteed by contract, but practically should differ.
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
