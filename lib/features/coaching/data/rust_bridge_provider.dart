import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/generated/racecoach/v1/track.pb.dart';
import 'package:race_coach/features/coaching/data/cue_config_repository.dart';
import 'package:race_coach/features/coaching/data/reference_lap_service.dart';
import 'package:race_coach/features/coaching/domain/audio_mode.dart';
import 'package:race_coach/features/track/data/track_service.dart';
import 'package:race_coach/src/rust/api/coaching_api.dart' as rust;
import 'package:race_coach/src/rust/types.dart' as rust;

// =============================================================================
// Rust Bridge Providers — Riverpod wrappers for the Rust analysis engine
// =============================================================================

/// Whether a Rust analysis session is currently active.
final rustSessionActiveProvider = StateProvider<bool>((ref) => false);

/// Manages the Rust analysis session lifecycle.
///
/// Watches the audio mode and track selection. When AudioMode.coach is
/// selected and a track is configured, it automatically creates a Rust
/// session. When the mode changes away from coach, it destroys the session.
final rustSessionManagerProvider = Provider<void>((ref) {
  final audioMode = ref.watch(audioModeProvider);
  final trackState = ref.watch(trackServiceProvider);

  if (audioMode == AudioMode.coach && trackState.hasSelection) {
    _createRustSession(ref, trackState);
  } else {
    _destroyRustSession(ref);
  }
});

Future<void> _createRustSession(Ref ref, TrackState trackState) async {
  final config = trackState.selectedConfig!;
  final track = trackState.selectedTrack!;

  final rustConfig = rust.SessionConfig(
    track: _toRustTrackConfig(track, config),
    analysis: _defaultAnalysisConfig(),
    useMph: true, // TODO: read from user settings
  );

  // Ensure persisted coaching preferences are loaded before session creation.
  await ref.read(cueConfigProvider.notifier).initialized;

  final cueConfig = ref.read(cueConfigProvider);
  final rustCueConfig = toRustCueConfig(cueConfig);

  await rust.createSession(config: rustConfig, cueConfig: rustCueConfig);
  ref.read(rustSessionActiveProvider.notifier).state = true;

  // Auto-load the best reference lap for this track.
  final trackName = '${track.name} ${config.name}'.trim();
  unawaited(
    ref
        .read(referenceLapServiceProvider.notifier)
        .autoLoadForTrack(trackName)
        .then((loaded) {
          if (loaded) {
            debugPrint(
              '[RustBridge] Auto-loaded reference lap for "$trackName"',
            );
          } else {
            debugPrint(
              '[RustBridge] No reference lap available for "$trackName"',
            );
          }
        })
        .catchError((Object e) {
          debugPrint('[RustBridge] Error auto-loading reference lap: $e');
        }),
  );
}

Future<void> _destroyRustSession(Ref ref) async {
  if (ref.read(rustSessionActiveProvider)) {
    await rust.destroySession();
    ref.read(rustSessionActiveProvider.notifier).state = false;
  }
}

// =============================================================================
// FrameOutput provider — exposes the latest Rust analysis output
// =============================================================================

/// The latest analysis output from the Rust engine.
///
/// Updated every frame (25 Hz) by CoachModeBridge when in coach mode.
final rustFrameOutputProvider = StateProvider<rust.FrameOutput?>((ref) => null);

/// Delta-T in seconds (positive = behind reference, negative = ahead).
final deltaTProvider = Provider<double>((ref) {
  return ref.watch(rustFrameOutputProvider)?.deltaTSeconds ?? 0.0;
});

/// Delta-T trend (rate of change — is the gap growing or closing?).
final deltaTTrendProvider = Provider<double>((ref) {
  return ref.watch(rustFrameOutputProvider)?.deltaTTrend ?? 0.0;
});

/// Current grip utilization (0.0 – 1.0+).
final gripUtilizationProvider = Provider<double>((ref) {
  return ref.watch(rustFrameOutputProvider)?.gripUtilization ?? 0.0;
});

/// Whether braking is currently detected.
final isBrakingProvider = Provider<bool>((ref) {
  return ref.watch(rustFrameOutputProvider)?.brakingState.isBraking ?? false;
});

/// Current track distance in meters.
final trackDistanceProvider = Provider<double>((ref) {
  return ref.watch(rustFrameOutputProvider)?.trackDistanceM ?? 0.0;
});

/// Lap distance as a percentage (0.0 – 1.0).
final lapDistancePctProvider = Provider<double>((ref) {
  return ref.watch(rustFrameOutputProvider)?.lapDistancePct ?? 0.0;
});

/// Friction circle state from Rust engine.
final frictionCircleProvider = Provider<rust.FrictionCircleState?>((ref) {
  return ref.watch(rustFrameOutputProvider)?.frictionCircle;
});

/// Braking state from Rust engine.
final brakingStateProvider = Provider<rust.BrakingState?>((ref) {
  return ref.watch(rustFrameOutputProvider)?.brakingState;
});

/// Current sector number (1-based).
final currentSectorProvider = Provider<int>((ref) {
  return ref.watch(rustFrameOutputProvider)?.currentSector ?? 1;
});

/// Current sector delta vs reference (seconds).
final sectorDeltaProvider = Provider<double?>((ref) {
  return ref.watch(rustFrameOutputProvider)?.sectorDelta;
});

// =============================================================================
// Type converters — Dart proto types ↔ Rust FFI types
// =============================================================================

rust.TrackConfig _toRustTrackConfig(Track track, TrackConfiguration config) {
  return rust.TrackConfig(
    name: track.name,
    finishLineA: rust.LatLng(
      lat: config.finishLineA.latitude,
      lng: config.finishLineA.longitude,
    ),
    finishLineB: rust.LatLng(
      lat: config.finishLineB.latitude,
      lng: config.finishLineB.longitude,
    ),
    corners: config.corners
        .map(
          (c) => rust.Corner(
            number: c.number,
            name: c.name,
            entry: rust.LatLng(lat: c.entry.latitude, lng: c.entry.longitude),
            apex: rust.LatLng(lat: c.apex.latitude, lng: c.apex.longitude),
            exit: rust.LatLng(lat: c.exit.latitude, lng: c.exit.longitude),
          ),
        )
        .toList(),
    sectorSplits: config.sectors
        .map(
          (s) => rust.SectorSplit(
            sectorNumber: s.sectorNumber,
            pointA: rust.LatLng(
              lat: s.pointA.latitude,
              lng: s.pointA.longitude,
            ),
            pointB: rust.LatLng(
              lat: s.pointB.latitude,
              lng: s.pointB.longitude,
            ),
          ),
        )
        .toList(),
    centerline: config.centerline
        .map((p) => rust.LatLng(lat: p.latitude, lng: p.longitude))
        .toList(),
    trackLengthM: config.hasLengthMeters()
        ? config.lengthMeters.toDouble()
        : null,
  );
}

rust.AnalysisConfig _defaultAnalysisConfig() {
  return const rust.AnalysisConfig(
    speedIntegratedDistance: true,
    centerlineProjection: false,
    sectorTimer: true,
    deltaT: true,
    brakingGOnset: true,
    cornerSpeed: false,
    trailBraking: true,
    jerkAnalysis: true,
    speedDerivative: false,
    frictionCircle: true,
    combinedG: false,
    headingMatching: false,
    curvatureMatching: false,
    energyDissipation: false,
    brakingEfficiency: false,
    throttleAnalysis: false,
    brakePressure: false,
  );
}
