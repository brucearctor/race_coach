import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/coaching/domain/cue_config.dart';

void main() {
  // ===========================================================================
  // DartCueConfig — constructor & defaults
  // ===========================================================================

  group('DartCueConfig defaults', () {
    test('default constructor has expected values', () {
      const config = DartCueConfig();
      expect(config.verbosity, 2);
      expect(config.enableBrakingCues, true);
      expect(config.enableCornerSpeedCues, true);
      expect(config.enableDeltaTCues, true);
      expect(config.enableCoastingCues, true);
      expect(config.enableGripLimitCues, true);
      expect(config.enableTrailBrakingCues, false);
      expect(config.enableJerkCues, false);
      expect(config.deltaTThresholdS, 0.5);
      expect(config.coastingThreshold, 0.15);
      expect(config.overDrivingThreshold, 0.95);
      expect(config.brakingDeltaThresholdM, 5.0);
      expect(config.cornerSpeedThresholdKmh, 3.0);
      expect(config.perCornerCooldownS, 3.0);
      expect(config.perTypeCooldownS, 1.0);
      expect(config.minCueIntervalS, 3);
      expect(config.speechRate, 0.5);
      expect(config.volume, 1.0);
    });
  });

  // ===========================================================================
  // Presets
  // ===========================================================================

  group('DartCueConfig presets', () {
    test('presetLow has verbosity 0', () {
      expect(DartCueConfig.presetLow.verbosity, 0);
    });

    test('presetMedium has verbosity 1', () {
      expect(DartCueConfig.presetMedium.verbosity, 1);
    });

    test('presetHigh has verbosity 2', () {
      expect(DartCueConfig.presetHigh.verbosity, 2);
    });

    test('presetLow disables coasting and trail braking', () {
      expect(DartCueConfig.presetLow.enableCoastingCues, false);
      expect(DartCueConfig.presetLow.enableTrailBrakingCues, false);
      expect(DartCueConfig.presetLow.enableJerkCues, false);
    });

    test('presetMedium enables braking and corner speed', () {
      expect(DartCueConfig.presetMedium.enableBrakingCues, true);
      expect(DartCueConfig.presetMedium.enableCornerSpeedCues, true);
    });

    test('presetHigh matches default constructor', () {
      const preset = DartCueConfig.presetHigh;
      const defaults = DartCueConfig();
      // Core fields should match (presets don't set audio fields)
      expect(preset.verbosity, defaults.verbosity);
      expect(preset.enableBrakingCues, defaults.enableBrakingCues);
      expect(preset.enableCoastingCues, defaults.enableCoastingCues);
    });
  });

  // ===========================================================================
  // copyWith
  // ===========================================================================

  group('DartCueConfig copyWith', () {
    test('copyWith changes only specified fields', () {
      const original = DartCueConfig();
      final modified = original.copyWith(verbosity: 0, volume: 0.5);
      expect(modified.verbosity, 0);
      expect(modified.volume, 0.5);
      // Unmodified fields preserved
      expect(modified.enableBrakingCues, original.enableBrakingCues);
      expect(modified.speechRate, original.speechRate);
      expect(modified.deltaTThresholdS, original.deltaTThresholdS);
    });

    test('copyWith with no args returns equal config', () {
      const original = DartCueConfig();
      final copy = original.copyWith();
      expect(copy, original);
    });
  });

  // ===========================================================================
  // JSON serialization
  // ===========================================================================

  group('DartCueConfig JSON', () {
    test('round-trip toJson → fromJson preserves all fields', () {
      const original = DartCueConfig(
        verbosity: 1,
        enableBrakingCues: false,
        enableCornerSpeedCues: false,
        enableDeltaTCues: false,
        enableCoastingCues: false,
        enableGripLimitCues: false,
        enableTrailBrakingCues: true,
        enableJerkCues: true,
        deltaTThresholdS: 1.5,
        coastingThreshold: 0.25,
        overDrivingThreshold: 0.85,
        brakingDeltaThresholdM: 10.0,
        cornerSpeedThresholdKmh: 5.0,
        perCornerCooldownS: 5.0,
        perTypeCooldownS: 2.0,
        minCueIntervalS: 5,
        speechRate: 0.7,
        volume: 0.8,
      );
      final json = original.toJson();
      final restored = DartCueConfig.fromJson(json);
      expect(restored, original);
    });

    test('fromJson with empty map returns defaults', () {
      final config = DartCueConfig.fromJson(<String, dynamic>{});
      expect(config, const DartCueConfig());
    });

    test('toJson produces valid JSON string', () {
      const config = DartCueConfig();
      final jsonStr = jsonEncode(config.toJson());
      expect(jsonStr, isNotEmpty);
      // Round-trip via string
      final decoded = DartCueConfig.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(decoded, config);
    });
  });

  // ===========================================================================
  // fromJson clamping (defensive input validation)
  // ===========================================================================

  group('DartCueConfig fromJson clamping', () {
    test('verbosity is clamped to 0–2', () {
      final tooHigh = DartCueConfig.fromJson({'verbosity': 999});
      expect(tooHigh.verbosity, 2);

      final tooLow = DartCueConfig.fromJson({'verbosity': -1});
      expect(tooLow.verbosity, 0);
    });

    test('speechRate is clamped to 0.0–1.0', () {
      final high = DartCueConfig.fromJson({'speechRate': 5.0});
      expect(high.speechRate, 1.0);

      final low = DartCueConfig.fromJson({'speechRate': -0.5});
      expect(low.speechRate, 0.0);
    });

    test('volume is clamped to 0.0–1.0', () {
      final high = DartCueConfig.fromJson({'volume': 2.0});
      expect(high.volume, 1.0);
    });

    test('minCueIntervalS is clamped to 1–30', () {
      final tooLow = DartCueConfig.fromJson({'minCueIntervalS': 0});
      expect(tooLow.minCueIntervalS, 1);

      final tooHigh = DartCueConfig.fromJson({'minCueIntervalS': 100});
      expect(tooHigh.minCueIntervalS, 30);
    });

    test('deltaTThresholdS is clamped to 0.1–10.0', () {
      final tooLow = DartCueConfig.fromJson({'deltaTThresholdS': 0.0});
      expect(tooLow.deltaTThresholdS, 0.1);
    });

    test('overDrivingThreshold is clamped to 0.5–1.0', () {
      final tooLow = DartCueConfig.fromJson({'overDrivingThreshold': 0.1});
      expect(tooLow.overDrivingThreshold, 0.5);
    });
  });

  // ===========================================================================
  // Equality & hashCode
  // ===========================================================================

  group('DartCueConfig equality', () {
    test('two default configs are equal', () {
      const a = DartCueConfig();
      const b = DartCueConfig();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('configs with different verbosity are not equal', () {
      const a = DartCueConfig(verbosity: 0);
      const b = DartCueConfig(verbosity: 2);
      expect(a, isNot(b));
    });

    test('configs with different toggles are not equal', () {
      const a = DartCueConfig(enableBrakingCues: true);
      const b = DartCueConfig(enableBrakingCues: false);
      expect(a, isNot(b));
    });

    test('configs with different thresholds are not equal', () {
      const a = DartCueConfig(deltaTThresholdS: 0.5);
      const b = DartCueConfig(deltaTThresholdS: 1.0);
      expect(a, isNot(b));
    });
  });
}
