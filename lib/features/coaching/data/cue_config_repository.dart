import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/coaching/domain/cue_config.dart';
import 'package:race_coach/src/rust/api/coaching_api.dart' as rust;
import 'package:race_coach/src/rust/types.dart' as rust;

// =============================================================================
// CueConfigNotifier — manages coaching cue configuration state
// =============================================================================

/// Riverpod notifier for the coaching cue configuration.
///
/// Persists to SharedPreferences and pushes changes to the Rust engine
/// via `setCueConfig()`.
class CueConfigNotifier extends StateNotifier<DartCueConfig> {
  CueConfigNotifier() : super(const DartCueConfig()) {
    _initialized = _loadSaved();
  }

  /// Completes when persisted config has been loaded from SharedPreferences.
  /// Await this before reading state if you need the persisted values
  /// (e.g. during session creation).
  late final Future<void> _initialized;

  /// Public accessor so callers can await initialization.
  Future<void> get initialized => _initialized;

  Future<void> _loadSaved() async {
    state = await DartCueConfig.load();
  }

  /// Update the config, persist, and push to Rust.
  Future<void> update(DartCueConfig config) async {
    if (state == config) return;
    state = config;
    await config.save();
    await _pushToRust(config);
  }

  /// Apply a verbosity preset (Low / Medium / High).
  Future<void> applyPreset(int verbosity) async {
    final DartCueConfig preset;
    switch (verbosity) {
      case 0:
        preset = DartCueConfig.presetLow.copyWith(
          speechRate: state.speechRate,
          volume: state.volume,
        );
      case 1:
        preset = DartCueConfig.presetMedium.copyWith(
          speechRate: state.speechRate,
          volume: state.volume,
        );
      default:
        preset = DartCueConfig.presetHigh.copyWith(
          speechRate: state.speechRate,
          volume: state.volume,
        );
    }
    await update(preset);
  }

  /// Reset to factory defaults.
  Future<void> resetToDefaults() async {
    await update(const DartCueConfig());
  }

  /// Push current config to the Rust engine (if a session is active).
  Future<void> _pushToRust(DartCueConfig config) async {
    try {
      await rust.setCueConfig(config: toRustCueConfig(config));
    } catch (e) {
      debugPrint('[CueConfig] Failed to push config to Rust: $e');
    }
  }
}

/// Convert a [DartCueConfig] to the FRB-generated [rust.CueConfig].
rust.CueConfig toRustCueConfig(DartCueConfig config) {
  return rust.CueConfig(
    verbosity: config.verbosity,
    enableBrakingCues: config.enableBrakingCues,
    enableCornerSpeedCues: config.enableCornerSpeedCues,
    enableDeltaTCues: config.enableDeltaTCues,
    enableCoastingCues: config.enableCoastingCues,
    enableGripLimitCues: config.enableGripLimitCues,
    enableTrailBrakingCues: config.enableTrailBrakingCues,
    enableJerkCues: config.enableJerkCues,
    deltaTThresholdS: config.deltaTThresholdS,
    coastingThreshold: config.coastingThreshold,
    overDrivingThreshold: config.overDrivingThreshold,
    brakingDeltaThresholdM: config.brakingDeltaThresholdM,
    cornerSpeedThresholdKmh: config.cornerSpeedThresholdKmh,
    perCornerCooldownS: config.perCornerCooldownS,
    perTypeCooldownS: config.perTypeCooldownS,
  );
}

/// Global provider for the coaching cue configuration.
final cueConfigProvider =
    StateNotifierProvider<CueConfigNotifier, DartCueConfig>((ref) {
      return CueConfigNotifier();
    });
