import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/audio_coach.dart';
import 'package:race_coach/features/coaching/domain/audio_mode.dart';
import 'package:race_coach/features/coaching/domain/coaching_cue.dart';
import 'package:race_coach/features/racebox/data/racebox_service.dart';
import 'package:race_coach/features/track/data/track_service.dart';

// =============================================================================
// Turn Announcer — speaks corner names as the driver approaches
// =============================================================================

/// Activation distance threshold in meters — announce when the driver is
/// within this distance of a corner's entry point.
const double _announceDistanceMeters = 100.0;

/// Cooldown duration — don't re-announce the same corner within this window.
const Duration _announceCooldown = Duration(seconds: 15);

/// Watches GPS data and announces turn names via TTS on approach.
///
/// Active when [audioModeProvider] is [AudioMode.turnAnnouncer] or
/// [AudioMode.coach].  Watch this provider from the live dashboard to
/// keep the pipeline alive.
final turnAnnouncerProvider = Provider<void>((ref) {
  final mode = ref.watch(audioModeProvider);

  // Only active for turn-aware modes.
  if (mode != AudioMode.turnAnnouncer && mode != AudioMode.coach) return;

  final config = ref.watch(selectedConfigProvider);
  if (config == null || config.corners.isEmpty) return;

  final audioCoach = ref.read(audioCoachProvider);

  // Track recently announced corners: corner number → last announce time.
  final announced = <int, DateTime>{};

  ref.listen(
    raceBoxDataStreamProvider,
    (previous, next) {
      final data = next.valueOrNull;
      if (data == null) return;

      // Skip invalid GPS.
      if (data.latitude == 0.0 && data.longitude == 0.0) return;

      final now = DateTime.now();

      for (final corner in config.corners) {
        if (!corner.hasEntry()) continue;

        final distance = distanceMetersForTesting(
          data.latitude,
          data.longitude,
          corner.entry.latitude,
          corner.entry.longitude,
        );

        if (distance < _announceDistanceMeters) {
          // Check cooldown.
          final lastAnnounce = announced[corner.number];
          if (lastAnnounce != null &&
              now.difference(lastAnnounce) < _announceCooldown) {
            continue;
          }

          announced[corner.number] = now;

          final spokenName = shortNameForTesting(corner.name);
          debugPrint('[TurnAnnouncer] 📢 $spokenName '
              '(${distance.toStringAsFixed(0)}m from entry)');

          audioCoach.speak(CoachingCue(
            type: CoachingCueType.turnAnnouncement,
            message: spokenName,
            priority: CuePriority.medium,
            timestamp: now,
          ));
        }
      }
    },
  );
});

// ── Helpers ────────────────────────────────────────────────────────────

/// Extract a short, TTS-friendly name from a corner name.
///
/// If the name contains parentheses (e.g. "Cyclone (T8)"), returns the
/// part before the parenthesis, trimmed.  Otherwise returns the full name.
@visibleForTesting
String shortNameForTesting(String name) {
  final parenIndex = name.indexOf('(');
  if (parenIndex > 0) {
    return name.substring(0, parenIndex).trim();
  }
  return name;
}

/// Haversine distance between two GPS coordinates in meters.
@visibleForTesting
double distanceMetersForTesting(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const R = 6371000.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
