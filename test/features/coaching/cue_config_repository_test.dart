import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:race_coach/features/coaching/data/cue_config_repository.dart';
import 'package:race_coach/features/coaching/domain/cue_config.dart';

void main() {
  // ===========================================================================
  // toRustCueConfig — field mapping
  // ===========================================================================

  group('toRustCueConfig', () {
    test('maps all fields from DartCueConfig to Rust CueConfig', () {
      const dart = DartCueConfig(
        verbosity: 1,
        enableBrakingCues: false,
        enableCornerSpeedCues: false,
        enableDeltaTCues: true,
        enableCoastingCues: false,
        enableGripLimitCues: true,
        enableTrailBrakingCues: true,
        enableJerkCues: true,
        deltaTThresholdS: 2.0,
        coastingThreshold: 0.3,
        overDrivingThreshold: 0.8,
        brakingDeltaThresholdM: 8.0,
        cornerSpeedThresholdKmh: 6.0,
        perCornerCooldownS: 5.0,
        perTypeCooldownS: 3.0,
      );

      final rust = toRustCueConfig(dart);

      expect(rust.verbosity, 1);
      expect(rust.enableBrakingCues, false);
      expect(rust.enableCornerSpeedCues, false);
      expect(rust.enableDeltaTCues, true);
      expect(rust.enableCoastingCues, false);
      expect(rust.enableGripLimitCues, true);
      expect(rust.enableTrailBrakingCues, true);
      expect(rust.enableJerkCues, true);
      expect(rust.deltaTThresholdS, 2.0);
      expect(rust.coastingThreshold, 0.3);
      expect(rust.overDrivingThreshold, 0.8);
      expect(rust.brakingDeltaThresholdM, 8.0);
      expect(rust.cornerSpeedThresholdKmh, 6.0);
      expect(rust.perCornerCooldownS, 5.0);
      expect(rust.perTypeCooldownS, 3.0);
    });

    test('default DartCueConfig maps to expected Rust defaults', () {
      const dart = DartCueConfig();
      final rust = toRustCueConfig(dart);
      expect(rust.verbosity, 2);
      expect(rust.enableBrakingCues, true);
      expect(rust.enableTrailBrakingCues, false);
      expect(rust.enableJerkCues, false);
    });
  });

  // ===========================================================================
  // CueConfigNotifier — initialization & provider
  // ===========================================================================

  group('CueConfigNotifier', () {
    setUp(() {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
    });

    test('cueConfigProvider starts with default state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final config = container.read(cueConfigProvider);
      expect(config.verbosity, 2); // default
      expect(config.enableBrakingCues, true);
    });

    test('initialized completes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cueConfigProvider.notifier);
      // Should complete without error
      await notifier.initialized;
    });

    test('update changes state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cueConfigProvider.notifier);
      await notifier.initialized;

      await notifier.update(const DartCueConfig(verbosity: 0));
      final config = container.read(cueConfigProvider);
      expect(config.verbosity, 0);
    });

    test('update with same config is no-op', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cueConfigProvider.notifier);
      await notifier.initialized;

      // Read initial
      final initial = container.read(cueConfigProvider);

      // Update with identical config
      await notifier.update(initial);

      // State reference should be same (no state change)
      final after = container.read(cueConfigProvider);
      expect(identical(initial, after), isTrue);
    });

    test('applyPreset 0 sets low verbosity', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cueConfigProvider.notifier);
      await notifier.initialized;

      await notifier.applyPreset(0);
      final config = container.read(cueConfigProvider);
      expect(config.verbosity, 0);
    });

    test('applyPreset 1 sets medium verbosity', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cueConfigProvider.notifier);
      await notifier.initialized;

      await notifier.applyPreset(1);
      final config = container.read(cueConfigProvider);
      expect(config.verbosity, 1);
    });

    test('applyPreset preserves audio settings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cueConfigProvider.notifier);
      await notifier.initialized;

      // Set custom audio settings
      await notifier.update(const DartCueConfig(speechRate: 0.8, volume: 0.6));

      // Apply a preset
      await notifier.applyPreset(0);
      final config = container.read(cueConfigProvider);

      // Audio settings should be preserved
      expect(config.speechRate, 0.8);
      expect(config.volume, 0.6);
      // But verbosity should have changed
      expect(config.verbosity, 0);
    });

    test('resetToDefaults restores factory defaults', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cueConfigProvider.notifier);
      await notifier.initialized;

      // Change things
      await notifier.update(
        const DartCueConfig(
          verbosity: 0,
          enableBrakingCues: false,
          deltaTThresholdS: 3.0,
        ),
      );

      // Reset
      await notifier.resetToDefaults();
      final config = container.read(cueConfigProvider);
      expect(config, const DartCueConfig());
    });

    test('persists and restores from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      // Create notifier, update, persist
      final container1 = ProviderContainer();
      final notifier1 = container1.read(cueConfigProvider.notifier);
      await notifier1.initialized;

      await notifier1.update(
        const DartCueConfig(
          verbosity: 0,
          enableBrakingCues: false,
          minCueIntervalS: 7,
        ),
      );
      container1.dispose();

      // Create new notifier — should load persisted values
      final container2 = ProviderContainer();
      final notifier2 = container2.read(cueConfigProvider.notifier);
      await notifier2.initialized;

      final config = container2.read(cueConfigProvider);
      expect(config.verbosity, 0);
      expect(config.enableBrakingCues, false);
      expect(config.minCueIntervalS, 7);
      container2.dispose();
    });
  });
}
