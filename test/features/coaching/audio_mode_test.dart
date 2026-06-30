import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/coaching/domain/audio_mode.dart';

void main() {
  // ===========================================================================
  // AudioMode enum basics
  // ===========================================================================

  group('AudioMode enum', () {
    test('has exactly 5 entries', () {
      expect(AudioMode.values.length, 5);
    });

    test('contains all expected modes', () {
      expect(
        AudioMode.values,
        containsAll([
          AudioMode.off,
          AudioMode.lapTimes,
          AudioMode.turnAnnouncer,
          AudioMode.coach,
          AudioMode.spotter,
        ]),
      );
    });
  });

  // ===========================================================================
  // AudioModeLabel extension — label
  // ===========================================================================

  group('AudioMode.label', () {
    test('each mode has a non-empty label', () {
      for (final mode in AudioMode.values) {
        expect(mode.label, isNotEmpty, reason: '$mode should have a label');
      }
    });

    test('labels are unique across all modes', () {
      final labels = AudioMode.values.map((m) => m.label).toList();
      expect(
        labels.toSet().length,
        labels.length,
        reason: 'All labels should be unique',
      );
    });

    test('off label is "Off"', () {
      expect(AudioMode.off.label, 'Off');
    });

    test('lapTimes label is "Lap Times"', () {
      expect(AudioMode.lapTimes.label, 'Lap Times');
    });

    test('turnAnnouncer label is "Turn Announcer"', () {
      expect(AudioMode.turnAnnouncer.label, 'Turn Announcer');
    });

    test('coach label is "Coach"', () {
      expect(AudioMode.coach.label, 'Coach');
    });

    test('spotter label is "Spotter"', () {
      expect(AudioMode.spotter.label, 'Spotter');
    });
  });

  // ===========================================================================
  // AudioModeLabel extension — description
  // ===========================================================================

  group('AudioMode.description', () {
    test('each mode has a non-empty description', () {
      for (final mode in AudioMode.values) {
        expect(
          mode.description,
          isNotEmpty,
          reason: '$mode should have a description',
        );
      }
    });

    test('descriptions are unique across all modes', () {
      final descriptions = AudioMode.values.map((m) => m.description).toList();
      expect(
        descriptions.toSet().length,
        descriptions.length,
        reason: 'All descriptions should be unique',
      );
    });
  });

  // ===========================================================================
  // AudioModeLabel extension — icon
  // ===========================================================================

  group('AudioMode.icon', () {
    test('each mode has a non-null icon', () {
      for (final mode in AudioMode.values) {
        expect(mode.icon, isNotNull, reason: '$mode should have an icon');
        expect(mode.icon, isA<IconData>());
      }
    });

    test('off mode uses volume_off icon', () {
      expect(AudioMode.off.icon, Icons.volume_off);
    });

    test('lapTimes mode uses timer icon', () {
      expect(AudioMode.lapTimes.icon, Icons.timer);
    });

    test('turnAnnouncer mode uses turn_right icon', () {
      expect(AudioMode.turnAnnouncer.icon, Icons.turn_right);
    });

    test('coach mode uses record_voice_over icon', () {
      expect(AudioMode.coach.icon, Icons.record_voice_over);
    });

    test('spotter mode uses visibility icon', () {
      expect(AudioMode.spotter.icon, Icons.visibility);
    });
  });

  // ===========================================================================
  // Riverpod provider default
  // ===========================================================================

  group('audioModeProvider', () {
    test('default value is turnAnnouncer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = container.read(audioModeProvider);
      expect(mode, AudioMode.turnAnnouncer);
    });

    test('can be updated via StateController', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(audioModeProvider.notifier).state = AudioMode.coach;
      expect(container.read(audioModeProvider), AudioMode.coach);
    });
  });
}
