import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/core/router/app_router.dart';
import 'package:race_coach/features/racebox/data/racebox_providers.dart';
import 'package:race_coach/features/racebox/data/racebox_service.dart';
import 'package:race_coach/features/racebox/presentation/racebox_status_widget.dart';
import 'package:race_coach/features/racebox/presentation/device_bottom_sheet.dart';
import 'package:race_coach/features/telemetry/data/adapters/racebox_adapter.dart';
import 'package:race_coach/features/session/data/session_recorder.dart';
import 'package:race_coach/features/coaching/data/turn_announcer.dart';
import 'package:race_coach/features/coaching/data/lap_time_announcer.dart';
import 'package:race_coach/features/live/data/lap_detection_bridge.dart';
import 'package:race_coach/features/track/data/track_service.dart';
import 'package:race_coach/features/live/presentation/widgets/speed_display.dart';
import 'package:race_coach/features/live/presentation/widgets/g_force_widget.dart';
import 'package:race_coach/features/live/presentation/widgets/lap_timer_widget.dart';
import 'package:race_coach/features/live/presentation/widgets/track_map_widget.dart';

/// Main live dashboard screen – the primary view while on track.
///
/// Portrait layout (when connected):
/// - Top:    SpeedDisplay (large, prominent)
/// - Middle: GForceWidget (left) + LapTimerWidget (right)
/// - Bottom: TrackMapWidget (GPS trail)
///
/// Shows an empty/connect state when no device is paired.
///
/// FAB toggles session recording. AppBar shows connection status and
/// a settings icon.
class LiveDashboardScreen extends ConsumerStatefulWidget {
  const LiveDashboardScreen({super.key});

  @override
  ConsumerState<LiveDashboardScreen> createState() =>
      _LiveDashboardScreenState();
}

class _LiveDashboardScreenState extends ConsumerState<LiveDashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      final service = ref.read(raceBoxServiceProvider);
      service.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = ref.watch(connectedDeviceIdProvider);
    final isConnected = deviceId != null;
    final isRecording = ref.watch(isRecordingProvider);

    // Only activate bridge providers when connected.
    if (isConnected) {
      ref.watch(raceBoxTelemetryBridgeProvider);
      ref.watch(sessionRecordingBridgeProvider);
      ref.watch(lapDetectionBridgeProvider);
      ref.watch(trackAutoDetectionProvider);
      ref.watch(turnAnnouncerProvider);
      ref.watch(lapTimeAnnouncerProvider);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const RaceBoxStatusWidget(),
        centerTitle: false,
        actions: [
          // ── BLE connect/disconnect button ─────────────────────
          if (!isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth),
              color: AppColors.primary,
              tooltip: 'Connect Device',
              onPressed: () => context.go(AppRoutes.deviceScanner),
            )
          else
            IconButton(
              icon: const Icon(Icons.bluetooth_connected),
              color: AppColors.success,
              tooltip: 'Device Info',
              onPressed: () => showDeviceBottomSheet(context, ref),
            ),

          // ── Sessions ──────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            color: AppColors.textSecondary,
            tooltip: 'Sessions',
            onPressed: () => context.go(AppRoutes.sessions),
          ),

          // ── Settings ─────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────
      body: isConnected ? _buildDashboard(isRecording) : _buildEmptyState(),

      // ── Session recording FAB (only when connected) ──────────────────
      floatingActionButton:
          isConnected ? _buildRecordingFab(isRecording) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // -----------------------------------------------------------------------
  // Connected dashboard
  // -----------------------------------------------------------------------

  Widget _buildDashboard(bool isRecording) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ── Speed display (top, prominent) ──────────────────
            const SpeedDisplay(),

            const SizedBox(height: 12),

            // ── Middle row: G-force + Lap timer ────────────────
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(child: GForceWidget()),
                  const SizedBox(width: 12),
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
    );
  }

  // -----------------------------------------------------------------------
  // Empty / disconnected state
  // -----------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bluetooth_searching,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 24),
          const Text(
            'No Device Connected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect a RaceBox or use phone GPS',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.deviceScanner),
            icon: const Icon(Icons.bluetooth),
            label: const Text('Connect Device'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Recording FAB
  // -----------------------------------------------------------------------

  Widget _buildRecordingFab(bool isRecording) {
    return FloatingActionButton.extended(
      onPressed: () {
        ref.read(isRecordingProvider.notifier).state = !isRecording;

        if (!isRecording) {
          ref.read(lapTimerProvider.notifier).start();
        } else {
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
    );
  }
}
