import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/coaching/data/audio_coach.dart';
import 'package:race_coach/features/track/presentation/track_selector_widget.dart';

// ── Settings State ─────────────────────────────────────────────────────

/// Which unit system to use for speed.
enum SpeedUnit { mph, kmh }

/// Which unit system to use for temperature.
enum TempUnit { fahrenheit, celsius }

/// Which GPS source to use.
enum GpsSource { racebox, phoneGps }

/// Immutable settings state.
class SettingsState {
  const SettingsState({
    this.speedUnit = SpeedUnit.mph,
    this.tempUnit = TempUnit.fahrenheit,
    this.audioEnabled = true,
    this.volume = 1.0,
    this.speechRate = 0.5,
    this.gpsSource = GpsSource.racebox,
    this.finishLineSet = false,
  });

  final SpeedUnit speedUnit;
  final TempUnit tempUnit;
  final bool audioEnabled;
  final double volume;
  final double speechRate;
  final GpsSource gpsSource;
  final bool finishLineSet;

  SettingsState copyWith({
    SpeedUnit? speedUnit,
    TempUnit? tempUnit,
    bool? audioEnabled,
    double? volume,
    double? speechRate,
    GpsSource? gpsSource,
    bool? finishLineSet,
  }) {
    return SettingsState(
      speedUnit: speedUnit ?? this.speedUnit,
      tempUnit: tempUnit ?? this.tempUnit,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      volume: volume ?? this.volume,
      speechRate: speechRate ?? this.speechRate,
      gpsSource: gpsSource ?? this.gpsSource,
      finishLineSet: finishLineSet ?? this.finishLineSet,
    );
  }
}

// ── State Notifier ─────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setSpeedUnit(SpeedUnit unit) =>
      state = state.copyWith(speedUnit: unit);

  void setTempUnit(TempUnit unit) =>
      state = state.copyWith(tempUnit: unit);

  void setAudioEnabled(bool enabled) =>
      state = state.copyWith(audioEnabled: enabled);

  void setVolume(double volume) =>
      state = state.copyWith(volume: volume);

  void setSpeechRate(double rate) =>
      state = state.copyWith(speechRate: rate);

  void setGpsSource(GpsSource source) =>
      state = state.copyWith(gpsSource: source);

  void setFinishLine() =>
      state = state.copyWith(finishLineSet: true);
}

// ── Provider ───────────────────────────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// ── Settings Screen ────────────────────────────────────────────────────

/// Application settings screen with dark-themed sections for units,
/// audio coaching, GPS source, finish line, and about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Units Section ─────────────────────────────────────
          _SectionHeader(title: 'Units'),

          _SettingsTile(
            icon: Icons.speed_rounded,
            title: 'Speed',
            trailing: SegmentedButton<SpeedUnit>(
              segments: const [
                ButtonSegment(value: SpeedUnit.mph, label: Text('MPH')),
                ButtonSegment(value: SpeedUnit.kmh, label: Text('KM/H')),
              ],
              selected: {settings.speedUnit},
              onSelectionChanged: (selected) {
                notifier.setSpeedUnit(selected.first);
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

          _SettingsTile(
            icon: Icons.thermostat_rounded,
            title: 'Temperature',
            trailing: SegmentedButton<TempUnit>(
              segments: const [
                ButtonSegment(value: TempUnit.fahrenheit, label: Text('°F')),
                ButtonSegment(value: TempUnit.celsius, label: Text('°C')),
              ],
              selected: {settings.tempUnit},
              onSelectionChanged: (selected) {
                notifier.setTempUnit(selected.first);
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

          const Divider(indent: 16, endIndent: 16),

          // ── Audio Coaching Section ────────────────────────────
          _SectionHeader(title: 'Audio Coaching'),

          SwitchListTile(
            title: const Text('Enable Audio Coaching'),
            subtitle: const Text('Spoken coaching cues during sessions'),
            value: settings.audioEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (value) {
              notifier.setAudioEnabled(value);
              ref.read(audioCoachProvider).setEnabled(value);
            },
            secondary: const Icon(
              Icons.record_voice_over_rounded,
              color: AppColors.textSecondary,
            ),
          ),

          _SettingsTile(
            icon: Icons.volume_up_rounded,
            title: 'Volume',
            subtitle:
                '${(settings.volume * 100).round()}%',
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: settings.volume,
                onChanged: (value) {
                  notifier.setVolume(value);
                  ref.read(audioCoachProvider).setVolume(value);
                },
                activeColor: AppColors.primary,
                inactiveColor: AppColors.divider,
              ),
            ),
          ),

          _SettingsTile(
            icon: Icons.speed_rounded,
            title: 'Speech Rate',
            subtitle:
                '${(settings.speechRate * 100).round()}%',
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: settings.speechRate,
                onChanged: (value) {
                  notifier.setSpeechRate(value);
                  ref.read(audioCoachProvider).setSpeechRate(value);
                },
                activeColor: AppColors.primary,
                inactiveColor: AppColors.divider,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(audioCoachProvider).speakTest();
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Test Audio'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── GPS Source Section ────────────────────────────────
          _SectionHeader(title: 'GPS Source'),

          RadioListTile<GpsSource>(
            title: const Text('RaceBox'),
            subtitle: const Text('External BLE GPS (25 Hz)'),
            value: GpsSource.racebox,
            // ignore: deprecated_member_use
            groupValue: settings.gpsSource,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value != null) notifier.setGpsSource(value);
            },
            secondary: const Icon(
              Icons.bluetooth_rounded,
              color: AppColors.textSecondary,
            ),
          ),

          RadioListTile<GpsSource>(
            title: const Text('Phone GPS'),
            subtitle: const Text('Built-in GPS (1 Hz)'),
            value: GpsSource.phoneGps,
            // ignore: deprecated_member_use
            groupValue: settings.gpsSource,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value != null) notifier.setGpsSource(value);
            },
            secondary: const Icon(
              Icons.phone_android_rounded,
              color: AppColors.textSecondary,
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Track Section ────────────────────────────────────
          _SectionHeader(title: 'Track'),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TrackSelectorWidget(),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Finish Line Section ──────────────────────────────
          _SectionHeader(title: 'Finish Line'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                notifier.setFinishLine();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Finish line set at current position'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.flag_rounded),
              label: const Text('Set Current Position as Finish Line'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
              ),
            ),
          ),

          if (settings.finishLineSet)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Finish line is set',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(indent: 16, endIndent: 16),

          // ── About Section ────────────────────────────────────
          _SectionHeader(title: 'About'),

          const _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Race Coach',
            subtitle: 'Version 0.1.0+1',
          ),

          const _SettingsTile(
            icon: Icons.build_rounded,
            title: 'Built with',
            subtitle: 'Flutter · Riverpod · flutter_map',
          ),

          const SizedBox(height: 80), // Space for FAB clearance
        ],
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
