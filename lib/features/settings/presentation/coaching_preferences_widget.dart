import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/coaching/data/audio_coach.dart';
import 'package:race_coach/features/coaching/data/cue_config_repository.dart';
import 'package:race_coach/features/coaching/domain/cue_config.dart';

/// Coaching preferences section for the settings screen.
///
/// Contains:
/// - Verbosity preset selector (Low / Medium / High)
/// - Per-cue-type toggles
/// - Dart-side audio settings (min interval, speech rate, volume)
/// - Collapsible "Advanced Thresholds" section
/// - Reset to Defaults button
class CoachingPreferencesWidget extends ConsumerStatefulWidget {
  const CoachingPreferencesWidget({super.key});

  @override
  ConsumerState<CoachingPreferencesWidget> createState() =>
      _CoachingPreferencesState();
}

class _CoachingPreferencesState
    extends ConsumerState<CoachingPreferencesWidget> {
  bool _showAdvanced = false;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(cueConfigProvider);
    final notifier = ref.read(cueConfigProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Verbosity Preset ───────────────────────────────────────
        _label('VERBOSITY'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Low')),
                    ButtonSegment(value: 1, label: Text('Medium')),
                    ButtonSegment(value: 2, label: Text('High')),
                  ],
                  selected: {config.verbosity.clamp(0, 2).toInt()},
                  onSelectionChanged: (selected) {
                    notifier.applyPreset(selected.first);
                    _applyMinInterval();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary;
                      }
                      return AppColors.surface;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.background;
                      }
                      return AppColors.textSecondary;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            _verbosityDescription(config.verbosity),
            style: const TextStyle(fontSize: 12, color: AppColors.textDim),
          ),
        ),

        const SizedBox(height: 8),

        // ── Per-Cue-Type Toggles ───────────────────────────────────
        _label('CUE TYPES'),
        _cueToggle(
          icon: Icons.stop_circle_outlined,
          label: 'Braking',
          subtitle: 'Brake earlier / later cues',
          value: config.enableBrakingCues,
          onChanged: (v) => _update(config.copyWith(enableBrakingCues: v)),
        ),
        _cueToggle(
          icon: Icons.speed_rounded,
          label: 'Corner Speed',
          subtitle: 'Carry more / less speed cues',
          value: config.enableCornerSpeedCues,
          onChanged: (v) => _update(config.copyWith(enableCornerSpeedCues: v)),
        ),
        _cueToggle(
          icon: Icons.timer_outlined,
          label: 'Delta Time',
          subtitle: 'Gaining / losing time cues',
          value: config.enableDeltaTCues,
          onChanged: (v) => _update(config.copyWith(enableDeltaTCues: v)),
        ),
        _cueToggle(
          icon: Icons.pause_circle_outline_rounded,
          label: 'Coasting',
          subtitle: 'Coasting detected warnings',
          value: config.enableCoastingCues,
          onChanged: (v) => _update(config.copyWith(enableCoastingCues: v)),
        ),
        _cueToggle(
          icon: Icons.radio_button_unchecked,
          label: 'Grip Limit',
          subtitle: 'Near grip limit warnings',
          value: config.enableGripLimitCues,
          onChanged: (v) => _update(config.copyWith(enableGripLimitCues: v)),
        ),
        _cueToggle(
          icon: Icons.trending_down_rounded,
          label: 'Trail Braking',
          subtitle: 'Trail braking technique cues',
          value: config.enableTrailBrakingCues,
          onChanged: (v) => _update(config.copyWith(enableTrailBrakingCues: v)),
        ),
        _cueToggle(
          icon: Icons.vibration_rounded,
          label: 'Jerk',
          subtitle: 'Abrupt input detection cues',
          value: config.enableJerkCues,
          onChanged: (v) => _update(config.copyWith(enableJerkCues: v)),
        ),

        const SizedBox(height: 8),

        // ── Audio Timing ───────────────────────────────────────────
        _label('AUDIO TIMING'),
        _sliderTile(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Min Cue Interval',
          subtitle: '${config.minCueIntervalS}s between cues',
          value: config.minCueIntervalS.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (v) {
            _update(config.copyWith(minCueIntervalS: v.round()));
            _applyMinInterval();
          },
        ),

        const SizedBox(height: 8),

        // ── Advanced Thresholds (collapsible) ──────────────────────
        InkWell(
          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  _showAdvanced
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Advanced Thresholds',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_showAdvanced) ...[
          _sliderTile(
            icon: Icons.timer_outlined,
            label: 'Delta-T Threshold',
            subtitle: '${config.deltaTThresholdS.toStringAsFixed(1)}s',
            value: config.deltaTThresholdS,
            min: 0.1,
            max: 3.0,
            divisions: 29,
            onChanged: (v) => _update(config.copyWith(deltaTThresholdS: v)),
          ),
          _sliderTile(
            icon: Icons.stop_circle_outlined,
            label: 'Braking Delta',
            subtitle: '${config.brakingDeltaThresholdM.toStringAsFixed(0)}m',
            value: config.brakingDeltaThresholdM,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) =>
                _update(config.copyWith(brakingDeltaThresholdM: v)),
          ),
          _sliderTile(
            icon: Icons.speed_rounded,
            label: 'Corner Speed',
            subtitle:
                '${config.cornerSpeedThresholdKmh.toStringAsFixed(0)} km/h',
            value: config.cornerSpeedThresholdKmh,
            min: 1,
            max: 15,
            divisions: 14,
            onChanged: (v) =>
                _update(config.copyWith(cornerSpeedThresholdKmh: v)),
          ),
          _sliderTile(
            icon: Icons.pause_circle_outline_rounded,
            label: 'Coasting Threshold',
            subtitle: '${(config.coastingThreshold * 100).toStringAsFixed(0)}%',
            value: config.coastingThreshold,
            min: 0.05,
            max: 0.50,
            divisions: 9,
            onChanged: (v) => _update(config.copyWith(coastingThreshold: v)),
          ),
          _sliderTile(
            icon: Icons.radio_button_unchecked,
            label: 'Over-driving Threshold',
            subtitle:
                '${(config.overDrivingThreshold * 100).toStringAsFixed(0)}%',
            value: config.overDrivingThreshold,
            min: 0.80,
            max: 1.00,
            divisions: 20,
            onChanged: (v) => _update(config.copyWith(overDrivingThreshold: v)),
          ),
          _sliderTile(
            icon: Icons.refresh_rounded,
            label: 'Corner Cooldown',
            subtitle: '${config.perCornerCooldownS.toStringAsFixed(1)}s',
            value: config.perCornerCooldownS,
            min: 1.0,
            max: 10.0,
            divisions: 18,
            onChanged: (v) => _update(config.copyWith(perCornerCooldownS: v)),
          ),
          _sliderTile(
            icon: Icons.refresh_rounded,
            label: 'Cue Type Cooldown',
            subtitle: '${config.perTypeCooldownS.toStringAsFixed(1)}s',
            value: config.perTypeCooldownS,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            onChanged: (v) => _update(config.copyWith(perTypeCooldownS: v)),
          ),
        ],

        const SizedBox(height: 8),

        // ── Reset to Defaults ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: OutlinedButton.icon(
            onPressed: () async {
              await notifier.resetToDefaults();
              if (mounted) {
                _applyMinInterval();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coaching preferences reset to defaults'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Future<void> _update(DartCueConfig config) async {
    await ref.read(cueConfigProvider.notifier).update(config);
  }

  /// Only sync the min-interval setting to AudioCoach, preserving the
  /// existing volume / speech-rate that the Audio Coaching sliders control.
  void _applyMinInterval() {
    final config = ref.read(cueConfigProvider);
    ref.read(audioCoachProvider).minInterval = Duration(
      seconds: config.minCueIntervalS,
    );
  }

  String _verbosityDescription(int verbosity) {
    switch (verbosity) {
      case 0:
        return 'Critical cues only — minimal interruption';
      case 1:
        return 'Balanced coaching — key feedback without overload';
      default:
        return 'Maximum feedback — every available cue';
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _cueToggle({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 28),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textDim),
        ),
      ),
      value: value,
      activeThumbColor: AppColors.primary,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      onChanged: onChanged,
    );
  }

  Widget _sliderTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.divider,
            ),
          ),
        ],
      ),
    );
  }
}
