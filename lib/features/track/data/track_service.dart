import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/generated/racecoach/v1/track.pb.dart';
import 'package:race_coach/features/track/data/track_library.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';

// =============================================================================
// Track Service — track library, auto-detection, and selection
// =============================================================================

/// Manages the track library and current track selection.
class TrackService extends StateNotifier<TrackState> {
  TrackService() : super(TrackState.initial());

  /// Load the local track library (hardcoded for now, Firestore later).
  void loadLibrary() {
    state = state.copyWith(
      availableTracks: getLocalTrackLibrary(),
    );
  }

  /// Manually select a track and configuration.
  void selectTrack(Track track, TrackConfiguration config) {
    state = state.copyWith(
      selectedTrack: track,
      selectedConfig: config,
      autoDetected: false,
    );
  }

  /// Clear the current selection.
  void clearSelection() {
    state = TrackState.initial().copyWith(
      availableTracks: state.availableTracks,
    );
  }

  /// Try to auto-detect which track we're at based on GPS coordinates.
  /// Returns true if a track was detected.
  bool tryAutoDetect(double latitude, double longitude) {
    for (final track in state.availableTracks) {
      if (!track.hasCenter()) continue;

      final distance = _haversineDistance(
        latitude,
        longitude,
        track.center.latitude,
        track.center.longitude,
      );

      if (distance <= track.autoDetectRadiusMeters) {
        // Found a match — pick the first config as default.
        if (track.configurations.isNotEmpty) {
          state = state.copyWith(
            selectedTrack: track,
            selectedConfig: track.configurations.first,
            autoDetected: true,
          );
          return true;
        }
      }
    }
    return false;
  }

  /// Update the finish line for the current configuration.
  /// Used for "set current position as finish line" flow.
  void setFinishLine(GpsData pointA, GpsData pointB) {
    if (state.selectedConfig == null) return;

    final updatedConfig = TrackConfiguration()
      ..mergeFromMessage(state.selectedConfig!)
      ..finishLineA = pointA
      ..finishLineB = pointB;

    state = state.copyWith(selectedConfig: updatedConfig);
  }

  /// Haversine distance between two GPS points in meters.
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;
}

/// Immutable state for track selection.
class TrackState {
  const TrackState({
    required this.availableTracks,
    this.selectedTrack,
    this.selectedConfig,
    this.autoDetected = false,
  });

  final List<Track> availableTracks;
  final Track? selectedTrack;
  final TrackConfiguration? selectedConfig;
  final bool autoDetected;

  factory TrackState.initial() => const TrackState(availableTracks: []);

  bool get hasSelection => selectedTrack != null && selectedConfig != null;

  TrackState copyWith({
    List<Track>? availableTracks,
    Track? selectedTrack,
    TrackConfiguration? selectedConfig,
    bool? autoDetected,
  }) {
    return TrackState(
      availableTracks: availableTracks ?? this.availableTracks,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      autoDetected: autoDetected ?? this.autoDetected,
    );
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

/// Track service provider — manages the track library and selection.
final trackServiceProvider =
    StateNotifierProvider<TrackService, TrackState>((ref) {
  final service = TrackService();
  service.loadLibrary();
  return service;
});

/// The currently selected track, or null.
final selectedTrackProvider = Provider<Track?>((ref) {
  return ref.watch(trackServiceProvider).selectedTrack;
});

/// The currently selected configuration, or null.
final selectedConfigProvider = Provider<TrackConfiguration?>((ref) {
  return ref.watch(trackServiceProvider).selectedConfig;
});

/// Auto-detects the track when GPS comes online.
/// Watch this provider to trigger auto-detection.
final trackAutoDetectionProvider = Provider<bool>((ref) {
  final gps = ref.watch(currentGpsProvider);
  if (gps == null) return false;

  final trackState = ref.read(trackServiceProvider);
  if (trackState.hasSelection) return true; // Already selected.

  return ref
      .read(trackServiceProvider.notifier)
      .tryAutoDetect(gps.latitude, gps.longitude);
});
