import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/racebox/data/racebox_providers.dart';
import 'package:race_coach/features/racebox/presentation/racebox_status_widget.dart';
import 'package:race_coach/features/telemetry/data/adapters/racebox_adapter.dart';
import 'package:race_coach/features/session/data/session_recorder.dart';
import 'package:race_coach/features/live/presentation/widgets/speed_display.dart';
import 'package:race_coach/features/live/presentation/widgets/g_force_widget.dart';
import 'package:race_coach/features/live/presentation/widgets/lap_timer_widget.dart';
import 'package:race_coach/features/live/presentation/widgets/track_map_widget.dart';
import 'package:race_coach/features/settings/presentation/settings_screen.dart';

/// Main live dashboard screen – the primary view while on track.
///
/// Portrait layout:
/// - Top:    SpeedDisplay (large, prominent)
/// - Middle: GForceWidget (left) + LapTimerWidget (right)
/// - Bottom: TrackMapWidget (GPS trail)
///
/// FAB toggles session recording. AppBar shows connection status and
/// a settings icon.
class LiveDashboardScreen extends ConsumerStatefulWidget {
  const LiveDashboardScreen({super.key});

  @override
  ConsumerState<LiveDashboardScreen> createState() =>
      _LiveDashboardScreenState();
}

class _LiveDashboardScreenState extends ConsumerState<LiveDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(isRecordingProvider);

    // Activate bridge providers — these pump data between layers:
    // RaceBox BLE → raceBoxDataProvider → TelemetryBus → dashboard widgets
    ref.watch(raceBoxTelemetryBridgeProvider);
    // Session recording bridge — auto-starts/stops with isRecordingProvider
    ref.watch(sessionRecordingBridgeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const RaceBoxStatusWidget(),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ── Speed display (top, prominent) ──────────────────
              const SpeedDisplay(),

              const SizedBox(height: 12),

              // ── Middle row: G-force + Lap timer ────────────────
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // G-force (left)
                    const Expanded(child: GForceWidget()),

                    const SizedBox(width: 12),

                    // Lap timer (right)
                    const Expanded(child: LapTimerWidget()),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Track map (bottom, takes remaining space) ──────
              const Expanded(child: TrackMapWidget()),
            ],
          ),
        ),
      ),

      // ── Session recording FAB ──────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(isRecordingProvider.notifier).state = !isRecording;

          if (!isRecording) {
            // Starting a new session – start lap timer too.
            ref.read(lapTimerProvider.notifier).start();
          } else {
            // Stopping session.
            ref.read(lapTimerProvider.notifier).stop();
          }
        },
        backgroundColor: isRecording ? AppColors.error : AppColors.success,
        foregroundColor: Colors.white,
        icon: Icon(
          isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded,
        ),
        label: Text(
          isRecording ? 'STOP' : 'RECORD',
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
