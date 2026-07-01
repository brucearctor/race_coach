import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Dart-side coaching cue configuration.
///
/// This mirrors the Rust `CueConfig` struct but adds Dart-side audio settings
/// (minCueIntervalS, speechRate, volume) that stay on the Dart side.
///
/// Persisted to SharedPreferences as JSON.
class DartCueConfig {
  const DartCueConfig({
    this.verbosity = 2,
    this.enableBrakingCues = true,
    this.enableCornerSpeedCues = true,
    this.enableDeltaTCues = true,
    this.enableCoastingCues = true,
    this.enableGripLimitCues = true,
    this.enableTrailBrakingCues = false,
    this.enableJerkCues = false,
    this.deltaTThresholdS = 0.5,
    this.coastingThreshold = 0.15,
    this.overDrivingThreshold = 0.95,
    this.brakingDeltaThresholdM = 5.0,
    this.cornerSpeedThresholdKmh = 3.0,
    this.perCornerCooldownS = 3.0,
    this.perTypeCooldownS = 1.0,
    this.minCueIntervalS = 3,
    this.speechRate = 0.5,
    this.volume = 1.0,
  });

  // ── Verbosity ──────────────────────────────────────────────────────
  /// 0 = Low (Critical + High only), 1 = Medium, 2 = High (all).
  final int verbosity;

  // ── Per-cue-type toggles ───────────────────────────────────────────
  final bool enableBrakingCues;
  final bool enableCornerSpeedCues;
  final bool enableDeltaTCues;
  final bool enableCoastingCues;
  final bool enableGripLimitCues;
  final bool enableTrailBrakingCues;
  final bool enableJerkCues;

  // ── CueEngine thresholds ───────────────────────────────────────────
  final double deltaTThresholdS;
  final double coastingThreshold;
  final double overDrivingThreshold;
  final double brakingDeltaThresholdM;

  // ── Analyzer thresholds ────────────────────────────────────────────
  final double cornerSpeedThresholdKmh;

  // ── Cooldowns ──────────────────────────────────────────────────────
  final double perCornerCooldownS;
  final double perTypeCooldownS;

  // ── Dart-side audio settings ───────────────────────────────────────
  /// Minimum seconds between spoken cues.
  final int minCueIntervalS;

  /// TTS speech rate (0.0 – 1.0).
  final double speechRate;

  /// TTS volume (0.0 – 1.0).
  final double volume;

  // ── Verbosity presets ──────────────────────────────────────────────

  /// Low verbosity preset — critical cues only, long cooldowns.
  static const DartCueConfig presetLow = DartCueConfig(
    verbosity: 0,
    deltaTThresholdS: 1.5,
    brakingDeltaThresholdM: 10.0,
    cornerSpeedThresholdKmh: 8.0,
    enableCoastingCues: false,
    enableTrailBrakingCues: false,
    enableJerkCues: false,
    minCueIntervalS: 6,
  );

  /// Medium verbosity preset — balanced coaching.
  static const DartCueConfig presetMedium = DartCueConfig(
    verbosity: 1,
    deltaTThresholdS: 0.5,
    brakingDeltaThresholdM: 5.0,
    cornerSpeedThresholdKmh: 3.0,
    minCueIntervalS: 3,
  );

  /// High verbosity preset — maximum feedback.
  static const DartCueConfig presetHigh = DartCueConfig(
    verbosity: 2,
    deltaTThresholdS: 0.3,
    brakingDeltaThresholdM: 3.0,
    cornerSpeedThresholdKmh: 2.0,
    enableTrailBrakingCues: true,
    enableJerkCues: true,
    minCueIntervalS: 2,
  );

  // ── copyWith ───────────────────────────────────────────────────────

  DartCueConfig copyWith({
    int? verbosity,
    bool? enableBrakingCues,
    bool? enableCornerSpeedCues,
    bool? enableDeltaTCues,
    bool? enableCoastingCues,
    bool? enableGripLimitCues,
    bool? enableTrailBrakingCues,
    bool? enableJerkCues,
    double? deltaTThresholdS,
    double? coastingThreshold,
    double? overDrivingThreshold,
    double? brakingDeltaThresholdM,
    double? cornerSpeedThresholdKmh,
    double? perCornerCooldownS,
    double? perTypeCooldownS,
    int? minCueIntervalS,
    double? speechRate,
    double? volume,
  }) {
    return DartCueConfig(
      verbosity: verbosity ?? this.verbosity,
      enableBrakingCues: enableBrakingCues ?? this.enableBrakingCues,
      enableCornerSpeedCues:
          enableCornerSpeedCues ?? this.enableCornerSpeedCues,
      enableDeltaTCues: enableDeltaTCues ?? this.enableDeltaTCues,
      enableCoastingCues: enableCoastingCues ?? this.enableCoastingCues,
      enableGripLimitCues: enableGripLimitCues ?? this.enableGripLimitCues,
      enableTrailBrakingCues:
          enableTrailBrakingCues ?? this.enableTrailBrakingCues,
      enableJerkCues: enableJerkCues ?? this.enableJerkCues,
      deltaTThresholdS: deltaTThresholdS ?? this.deltaTThresholdS,
      coastingThreshold: coastingThreshold ?? this.coastingThreshold,
      overDrivingThreshold: overDrivingThreshold ?? this.overDrivingThreshold,
      brakingDeltaThresholdM:
          brakingDeltaThresholdM ?? this.brakingDeltaThresholdM,
      cornerSpeedThresholdKmh:
          cornerSpeedThresholdKmh ?? this.cornerSpeedThresholdKmh,
      perCornerCooldownS: perCornerCooldownS ?? this.perCornerCooldownS,
      perTypeCooldownS: perTypeCooldownS ?? this.perTypeCooldownS,
      minCueIntervalS: minCueIntervalS ?? this.minCueIntervalS,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
    );
  }

  // ── JSON serialization ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'verbosity': verbosity,
    'enableBrakingCues': enableBrakingCues,
    'enableCornerSpeedCues': enableCornerSpeedCues,
    'enableDeltaTCues': enableDeltaTCues,
    'enableCoastingCues': enableCoastingCues,
    'enableGripLimitCues': enableGripLimitCues,
    'enableTrailBrakingCues': enableTrailBrakingCues,
    'enableJerkCues': enableJerkCues,
    'deltaTThresholdS': deltaTThresholdS,
    'coastingThreshold': coastingThreshold,
    'overDrivingThreshold': overDrivingThreshold,
    'brakingDeltaThresholdM': brakingDeltaThresholdM,
    'cornerSpeedThresholdKmh': cornerSpeedThresholdKmh,
    'perCornerCooldownS': perCornerCooldownS,
    'perTypeCooldownS': perTypeCooldownS,
    'minCueIntervalS': minCueIntervalS,
    'speechRate': speechRate,
    'volume': volume,
  };

  factory DartCueConfig.fromJson(Map<String, dynamic> json) {
    const defaults = DartCueConfig();
    return DartCueConfig(
      verbosity: json['verbosity'] as int? ?? defaults.verbosity,
      enableBrakingCues:
          json['enableBrakingCues'] as bool? ?? defaults.enableBrakingCues,
      enableCornerSpeedCues:
          json['enableCornerSpeedCues'] as bool? ??
          defaults.enableCornerSpeedCues,
      enableDeltaTCues:
          json['enableDeltaTCues'] as bool? ?? defaults.enableDeltaTCues,
      enableCoastingCues:
          json['enableCoastingCues'] as bool? ?? defaults.enableCoastingCues,
      enableGripLimitCues:
          json['enableGripLimitCues'] as bool? ?? defaults.enableGripLimitCues,
      enableTrailBrakingCues:
          json['enableTrailBrakingCues'] as bool? ??
          defaults.enableTrailBrakingCues,
      enableJerkCues:
          json['enableJerkCues'] as bool? ?? defaults.enableJerkCues,
      deltaTThresholdS:
          (json['deltaTThresholdS'] as num?)?.toDouble() ??
          defaults.deltaTThresholdS,
      coastingThreshold:
          (json['coastingThreshold'] as num?)?.toDouble() ??
          defaults.coastingThreshold,
      overDrivingThreshold:
          (json['overDrivingThreshold'] as num?)?.toDouble() ??
          defaults.overDrivingThreshold,
      brakingDeltaThresholdM:
          (json['brakingDeltaThresholdM'] as num?)?.toDouble() ??
          defaults.brakingDeltaThresholdM,
      cornerSpeedThresholdKmh:
          (json['cornerSpeedThresholdKmh'] as num?)?.toDouble() ??
          defaults.cornerSpeedThresholdKmh,
      perCornerCooldownS:
          (json['perCornerCooldownS'] as num?)?.toDouble() ??
          defaults.perCornerCooldownS,
      perTypeCooldownS:
          (json['perTypeCooldownS'] as num?)?.toDouble() ??
          defaults.perTypeCooldownS,
      minCueIntervalS:
          json['minCueIntervalS'] as int? ?? defaults.minCueIntervalS,
      speechRate:
          (json['speechRate'] as num?)?.toDouble() ?? defaults.speechRate,
      volume: (json['volume'] as num?)?.toDouble() ?? defaults.volume,
    );
  }

  // ── SharedPreferences persistence ──────────────────────────────────

  static const _prefsKey = 'cue_config';

  /// Load from SharedPreferences, or return defaults.
  static Future<DartCueConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return const DartCueConfig();
    try {
      return DartCueConfig.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const DartCueConfig();
    }
  }

  /// Persist to SharedPreferences.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(toJson()));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartCueConfig &&
          verbosity == other.verbosity &&
          enableBrakingCues == other.enableBrakingCues &&
          enableCornerSpeedCues == other.enableCornerSpeedCues &&
          enableDeltaTCues == other.enableDeltaTCues &&
          enableCoastingCues == other.enableCoastingCues &&
          enableGripLimitCues == other.enableGripLimitCues &&
          enableTrailBrakingCues == other.enableTrailBrakingCues &&
          enableJerkCues == other.enableJerkCues &&
          deltaTThresholdS == other.deltaTThresholdS &&
          coastingThreshold == other.coastingThreshold &&
          overDrivingThreshold == other.overDrivingThreshold &&
          brakingDeltaThresholdM == other.brakingDeltaThresholdM &&
          cornerSpeedThresholdKmh == other.cornerSpeedThresholdKmh &&
          perCornerCooldownS == other.perCornerCooldownS &&
          perTypeCooldownS == other.perTypeCooldownS &&
          minCueIntervalS == other.minCueIntervalS &&
          speechRate == other.speechRate &&
          volume == other.volume;

  @override
  int get hashCode => Object.hash(
    verbosity,
    enableBrakingCues,
    enableCornerSpeedCues,
    enableDeltaTCues,
    enableCoastingCues,
    enableGripLimitCues,
    enableTrailBrakingCues,
    enableJerkCues,
    Object.hash(
      deltaTThresholdS,
      coastingThreshold,
      overDrivingThreshold,
      brakingDeltaThresholdM,
      cornerSpeedThresholdKmh,
      perCornerCooldownS,
      perTypeCooldownS,
      minCueIntervalS,
      speechRate,
      volume,
    ),
  );
}
