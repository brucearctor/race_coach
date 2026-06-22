import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/coaching/data/lap_time_announcer.dart';

void main() {
  group('formatLapTimeForSpeechForTesting', () {
    test('formats minutes + seconds + tenths', () {
      // 1:42.300
      final d = const Duration(minutes: 1, seconds: 42, milliseconds: 300);
      expect(formatLapTimeForSpeechForTesting(d), '1 42 3');
    });

    test('pads seconds with leading zero', () {
      // 1:05.700
      final d = const Duration(minutes: 1, seconds: 5, milliseconds: 700);
      expect(formatLapTimeForSpeechForTesting(d), '1 05 7');
    });

    test('sub-minute uses "point" format', () {
      // 0:58.700
      final d = const Duration(seconds: 58, milliseconds: 700);
      expect(formatLapTimeForSpeechForTesting(d), '58 point 7');
    });

    test('exact seconds with no tenths', () {
      // 1:30.000
      final d = const Duration(minutes: 1, seconds: 30);
      expect(formatLapTimeForSpeechForTesting(d), '1 30 0');
    });

    test('handles 2+ minute laps', () {
      // 2:15.400
      final d = const Duration(minutes: 2, seconds: 15, milliseconds: 400);
      expect(formatLapTimeForSpeechForTesting(d), '2 15 4');
    });

    test('sub-10 second lap', () {
      final d = const Duration(seconds: 9, milliseconds: 500);
      expect(formatLapTimeForSpeechForTesting(d), '9 point 5');
    });

    test('truncates to tenths (ignores hundredths)', () {
      // 1:42.389 → tenths = 3 (not 4)
      final d = const Duration(minutes: 1, seconds: 42, milliseconds: 389);
      expect(formatLapTimeForSpeechForTesting(d), '1 42 3');
    });
  });

  group('buildLapMessageForTesting', () {
    test('first lap — no best time', () {
      final msg = buildLapMessageForTesting(
        lapTime: const Duration(minutes: 1, seconds: 42, milliseconds: 300),
        bestLapTime: null,
      );
      expect(msg, '1 42 3');
    });

    test('new best lap', () {
      final msg = buildLapMessageForTesting(
        lapTime: const Duration(minutes: 1, seconds: 40, milliseconds: 100),
        bestLapTime: const Duration(minutes: 1, seconds: 40, milliseconds: 100),
      );
      expect(msg, startsWith('New best!'));
      expect(msg, contains('1 40 1'));
    });

    test('faster than best triggers new best', () {
      final msg = buildLapMessageForTesting(
        lapTime: const Duration(minutes: 1, seconds: 39, milliseconds: 500),
        bestLapTime: const Duration(minutes: 1, seconds: 40, milliseconds: 100),
      );
      expect(msg, startsWith('New best!'));
    });

    test('slower by whole seconds', () {
      final msg = buildLapMessageForTesting(
        lapTime: const Duration(minutes: 1, seconds: 45, milliseconds: 300),
        bestLapTime: const Duration(minutes: 1, seconds: 42, milliseconds: 300),
      );
      expect(msg, contains('3 seconds slower'));
    });

    test('slower by 1 second uses singular', () {
      final msg = buildLapMessageForTesting(
        lapTime: const Duration(minutes: 1, seconds: 43, milliseconds: 300),
        bestLapTime: const Duration(minutes: 1, seconds: 42, milliseconds: 300),
      );
      expect(msg, contains('1 second slower'));
    });

    test('slower by sub-second uses tenths', () {
      final msg = buildLapMessageForTesting(
        lapTime: const Duration(minutes: 1, seconds: 42, milliseconds: 800),
        bestLapTime: const Duration(minutes: 1, seconds: 42, milliseconds: 300),
      );
      expect(msg, contains('tenths slower'));
    });
  });
}
