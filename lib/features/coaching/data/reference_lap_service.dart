import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';
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

  factory ReferenceLapState.empty() => const ReferenceLapState();

  ReferenceLapState copyWith({
    String? sessionId,
    int? lapNumber,
    double? lapTimeSeconds,
    bool? isLoaded,
    bool? isLoading,
  }) {
    return ReferenceLapState(
      sessionId: sessionId ?? this.sessionId,
      lapNumber: lapNumber ?? this.lapNumber,
      lapTimeSeconds: lapTimeSeconds ?? this.lapTimeSeconds,
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
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

    state = state.copyWith(isLoading: true);

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
  }

  /// Clear the loaded reference lap.
  Future<void> clear() async {
    await rust.clearReferenceLap();
    state = ReferenceLapState.empty();
  }
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
