import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available audio coaching modes.
enum AudioMode {
  /// No audio output.
  off,

  /// Announce lap times at finish line crossing only.
  lapTimes,

  /// Announce turn names as driver approaches each corner.
  turnAnnouncer,

  /// Active coaching with braking/speed/line feedback (needs reference lap).
  coach,

  /// Minimal — only important events (new best, big delta).
  spotter,
}

extension AudioModeLabel on AudioMode {
  String get label => switch (this) {
    AudioMode.off => 'Off',
    AudioMode.lapTimes => 'Lap Times',
    AudioMode.turnAnnouncer => 'Turn Announcer',
    AudioMode.coach => 'Coach',
    AudioMode.spotter => 'Spotter',
  };

  String get description => switch (this) {
    AudioMode.off => 'No audio',
    AudioMode.lapTimes => 'Lap time at finish line',
    AudioMode.turnAnnouncer => 'Turn names on approach',
    AudioMode.coach => 'Active feedback (needs reference lap)',
    AudioMode.spotter => 'Important events only',
  };

  IconData get icon => switch (this) {
    AudioMode.off => Icons.volume_off,
    AudioMode.lapTimes => Icons.timer,
    AudioMode.turnAnnouncer => Icons.turn_right,
    AudioMode.coach => Icons.record_voice_over,
    AudioMode.spotter => Icons.visibility,
  };
}

// ── Riverpod provider ──────────────────────────────────────────────────

final audioModeProvider = StateProvider<AudioMode>(
  (ref) => AudioMode.turnAnnouncer,
);
