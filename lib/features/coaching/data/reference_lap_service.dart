import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/reference_lap_prefs.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';
import 'package:race_coach/features/session/data/session_storage.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart';
import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/src/rust/api/coaching_api.dart' as rust;
import 'package:race_coach/src/rust/types.dart' as rust;

// =============================================================================
// Reference Lap Service — manages reference lap selection and loading
// =============================================================================

/// State for the reference lap.
class ReferenceLapState {
  const ReferenceLapState({
    this.sessionId,
    this.lapNumber,
    this.lapTimeSeconds,
    this.isLoaded = false,
    this.isLoading = false,
    this.error,
  });

  /// ID of the session the reference lap came from.
  final String? sessionId;

  /// Which lap number within that session.
  final int? lapNumber;

  /// Lap time in seconds.
  final double? lapTimeSeconds;

  /// Whether the reference lap is loaded in the Rust engine.
  final bool isLoaded;

  /// Whether we're currently loading a reference lap.
  final bool isLoading;

  /// Error message if loading failed.
  final String? error;

  factory ReferenceLapState.empty() => const ReferenceLapState();

  /// Formatted lap time for display (e.g., "1:42.3").
  String get formattedLapTime {
    if (lapTimeSeconds == null || lapTimeSeconds! <= 0) return '--:--.--';
    final totalMs = (lapTimeSeconds! * 1000).round();
    final minutes = totalMs ~/ 60000;
    final seconds = (totalMs % 60000) / 1000;
    if (minutes > 0) {
      return '$minutes:${seconds.toStringAsFixed(1).padLeft(4, '0')}';
    }
    return seconds.toStringAsFixed(1);
  }

  ReferenceLapState copyWith({
    String? sessionId,
    int? lapNumber,
    double? lapTimeSeconds,
    bool? isLoaded,
    bool? isLoading,
    String? error,
  }) {
    return ReferenceLapState(
      sessionId: sessionId ?? this.sessionId,
      lapNumber: lapNumber ?? this.lapNumber,
      lapTimeSeconds: lapTimeSeconds ?? this.lapTimeSeconds,
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Manages reference lap lifecycle — load from storage, send to Rust, clear.
class ReferenceLapService extends StateNotifier<ReferenceLapState> {
  ReferenceLapService(this.ref) : super(ReferenceLapState.empty());

  final Ref ref;

  /// Load a reference lap from raw telemetry frames.
  ///
  /// Typically called after user picks a "best lap" from session history.
  /// The frames are sent to the Rust engine for distance-indexing.
  Future<void> loadFromFrames({
    required List<rust.TelemetryInput> frames,
    required double lapTimeSeconds,
    String? sessionId,
    int? lapNumber,
  }) async {
    if (!ref.read(rustSessionActiveProvider)) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await rust.setReferenceLap(
        frames: frames,
        lapTimeS: lapTimeSeconds,
      );

      state = ReferenceLapState(
        sessionId: sessionId,
        lapNumber: lapNumber,
        lapTimeSeconds: lapTimeSeconds,
        isLoaded: true,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[ReferenceLapService] Error loading frames: $e');
      state = ReferenceLapState(
        isLoaded: false,
        isLoading: false,
        error: 'Failed to load reference lap: $e',
      );
    }
  }

  /// Load a specific lap from a saved session.
  ///
  /// Reads the session proto from disk, extracts the requested lap,
  /// converts proto TelemetryFrames → Rust TelemetryInput, and loads
  /// into the Rust engine.
  Future<bool> loadFromSession({
    required String sessionId,
    required int lapNumber,
    bool persist = true,
  }) async {
    if (!ref.read(rustSessionActiveProvider)) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final storage = ref.read(sessionStorageProvider);
      final session = await storage.loadSession(sessionId);

      // Find the requested lap.
      final lap = session.laps.firstWhere(
        (l) => l.lapNumber == lapNumber,
        orElse: () => Lap(),
      );

      if (lap.telemetry.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Lap $lapNumber has no telemetry data',
        );
        return false;
      }

      // Reject laps with invalid time.
      if (lap.lapTimeSeconds <= 0) {
        state = state.copyWith(
          isLoading: false,
          error: 'Lap $lapNumber has no valid lap time',
        );
        return false;
      }

      // Convert proto frames → Rust inputs.
      final rustFrames = lap.telemetry
          .where((f) => f.hasGps())
          .map(protoFrameToRustInput)
          .toList();

      if (rustFrames.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Lap $lapNumber has no GPS data',
        );
        return false;
      }

      await loadFromFrames(
        frames: rustFrames,
        lapTimeSeconds: lap.lapTimeSeconds,
        sessionId: sessionId,
        lapNumber: lapNumber,
      );

      // Persist the selection for next session start.
      if (persist && state.isLoaded) {
        final trackName = session.trackName;
        await ref.read(referenceLapPrefsProvider).saveSelection(
              trackName,
              ReferenceLapSelection(
                sessionId: sessionId,
                lapNumber: lapNumber,
              ),
            );
      }

      return state.isLoaded;
    } catch (e) {
      debugPrint('[ReferenceLapService] Error loading session: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load session: $e',
      );
      return false;
    }
  }

  /// Auto-load the best lap for the current track.
  ///
  /// First checks for a persisted selection. If none, scans all sessions
  /// for the given track and picks the fastest completed lap.
  Future<bool> autoLoadForTrack(String trackName) async {
    if (!ref.read(rustSessionActiveProvider)) return false;

    // 1. Check for a persisted selection.
    final prefs = ref.read(referenceLapPrefsProvider);
    final saved = await prefs.getSelection(trackName);
    if (saved != null) {
      debugPrint('[ReferenceLapService] Loading persisted reference: '
          '${saved.sessionId} lap ${saved.lapNumber}');
      final ok = await loadFromSession(
        sessionId: saved.sessionId,
        lapNumber: saved.lapNumber,
        persist: false, // Already persisted.
      );
      if (ok) return true;
      // If the saved session/lap is gone, fall through to best-lap search.
      debugPrint('[ReferenceLapService] Persisted reference not found, '
          'searching for best lap');
    }

    // 2. Find the best lap across all sessions for this track.
    final storage = ref.read(sessionStorageProvider);
    final sessions = await storage.listSessions();
    final trackSessions = sessions
        .where((s) =>
            s.trackName.toLowerCase().trim() ==
            trackName.toLowerCase().trim())
        .where((s) => s.bestLap != null)
        .toList();

    if (trackSessions.isEmpty) {
      debugPrint('[ReferenceLapService] No sessions with completed laps '
          'for track "$trackName"');
      return false;
    }

    // Sort by best lap time (fastest first).
    trackSessions.sort((a, b) => a.bestLap!.compareTo(b.bestLap!));

    // Try each candidate until one loads successfully.
    for (final candidate in trackSessions) {
      try {
        final session = await storage.loadSession(candidate.sessionId);
        Lap? bestLap;
        for (final lap in session.laps) {
          if (lap.lapTimeSeconds <= 0) continue;
          if (bestLap == null || lap.lapTimeSeconds < bestLap.lapTimeSeconds) {
            bestLap = lap;
          }
        }

        if (bestLap == null || bestLap.telemetry.isEmpty) continue;

        // Check that the lap has GPS data.
        final hasGps = bestLap.telemetry.any((f) => f.hasGps());
        if (!hasGps) continue;

        debugPrint('[ReferenceLapService] Auto-loading best lap: '
            '${candidate.sessionId} lap ${bestLap.lapNumber} '
            '(${bestLap.lapTimeSeconds}s)');

        final loaded = await loadFromSession(
          sessionId: candidate.sessionId,
          lapNumber: bestLap.lapNumber,
          persist: true,
        );
        if (loaded) return true;
        // If this candidate failed, try the next one.
      } catch (e) {
        debugPrint('[ReferenceLapService] Error loading candidate '
            '${candidate.sessionId}: $e');
        continue;
      }
    }

    debugPrint('[ReferenceLapService] No usable reference lap found '
        'for track "$trackName"');
    return false;
  }

  /// Clear the loaded reference lap.
  Future<void> clear({String? trackName}) async {
    await rust.clearReferenceLap();
    if (trackName != null) {
      await ref.read(referenceLapPrefsProvider).clearSelection(trackName);
    }
    state = ReferenceLapState.empty();
  }
}

// =============================================================================
// Type converter — Proto TelemetryFrame → Rust TelemetryInput
// =============================================================================

/// Convert a proto [TelemetryFrame] to a Rust [TelemetryInput].
///
/// Requires GPS data at minimum. Motion data is optional (defaults to 0).
rust.TelemetryInput protoFrameToRustInput(TelemetryFrame frame) {
  final gps = frame.gps;
  final motion = frame.hasMotion() ? frame.motion : null;

  // Prefer device_timestamp (actual measurement time) over arrival_timestamp.
  int timestampMs = 0;
  if (frame.hasDeviceTimestamp()) {
    timestampMs = frame.deviceTimestamp.seconds.toInt() * 1000 +
        frame.deviceTimestamp.nanos ~/ 1000000;
  } else if (frame.hasArrivalTimestamp()) {
    timestampMs = frame.arrivalTimestamp.seconds.toInt() * 1000 +
        frame.arrivalTimestamp.nanos ~/ 1000000;
  }

  return rust.TelemetryInput(
    timestampMs: BigInt.from(timestampMs),
    latitude: gps.latitude,
    longitude: gps.longitude,
    speedKmh: gps.speedKmh.toDouble(),
    headingDeg: gps.headingDegrees.toDouble(),
    altitudeM: gps.altitudeMeters.toDouble(),
    gLateral: motion?.gForceLateral.toDouble() ?? 0.0,
    gLongitudinal: motion?.gForceLongitudinal.toDouble() ?? 0.0,
    gVertical: motion?.gForceVertical.toDouble() ?? 1.0,
    satellites: gps.satellites,
    hdop: gps.hdop.toDouble(),
  );
}

// =============================================================================
// Riverpod providers
// =============================================================================

/// Reference lap service provider.
final referenceLapServiceProvider =
    StateNotifierProvider<ReferenceLapService, ReferenceLapState>((ref) {
  return ReferenceLapService(ref);
});

/// Whether a reference lap is currently loaded.
final hasReferenceLapProvider = Provider<bool>((ref) {
  return ref.watch(referenceLapServiceProvider).isLoaded;
});
