import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/coaching/data/debug_providers.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';
import 'package:race_coach/src/rust/types.dart' as rust;

/// Semi-transparent debug overlay shown during a live session when
/// developer mode is active.
///
/// Layout: fixed-position overlay with 5 panels:
///   1. GPS Quality (satellites, HDOP, fix quality)
///   2. Engine State (queue depth, cooldowns)
///   3. Cue Counters (emitted/filtered, lap & session)
///   4. Frame Output (delta-T, grip, braking)
///   5. Session Status (active, reference loaded)
///
/// Design: monospace text, semi-transparent dark background, compact layout.
/// The overlay sits in a Stack above the dashboard content.
class DebugHudOverlay extends ConsumerWidget {
  const DebugHudOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(developerModeProvider);
    if (!devMode) return const SizedBox.shrink();

    final gps = ref.watch(gpsQualityProvider);
    final engine = ref.watch(debugEngineStateProvider);
    final frame = ref.watch(rustFrameOutputProvider);
    final sessionActive = ref.watch(rustSessionActiveProvider);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xCC000000), // 80% black
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──────────────────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DEBUG HUD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      _StatusDot(active: sessionActive),
                      const SizedBox(width: 4),
                      Text(
                        sessionActive ? 'SESSION' : 'IDLE',
                        style: TextStyle(
                          fontSize: 9,
                          color: sessionActive
                              ? AppColors.success
                              : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    height: 8,
                    thickness: 0.5,
                    color: AppColors.divider,
                  ),

                  // ── Two-column layout ───────────────────────
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGpsPanel(gps),
                              const SizedBox(height: 4),
                              _buildEnginePanel(engine),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          width: 0.5,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          color: AppColors.divider,
                        ),

                        // Right column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCueCounters(engine),
                              const SizedBox(height: 4),
                              _buildFramePanel(frame),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Panel builders
  // -----------------------------------------------------------------------

  Widget _buildGpsPanel(GpsQuality gps) {
    final qualityColor = switch (gps.label) {
      'RTK' || 'EXCELLENT' => AppColors.signalExcellent,
      'GOOD' => AppColors.signalGood,
      'FAIR' => AppColors.signalFair,
      'POOR' || 'NO FIX' => AppColors.signalPoor,
      _ => AppColors.signalNone,
    };

    return _Panel(
      label: 'GPS',
      children: [
        _Row('SAT', '${gps.satellites}', color: qualityColor),
        _Row('HDOP', gps.hdop.toStringAsFixed(1), color: qualityColor),
        _Row('FIX', gps.label, color: qualityColor),
        _Row('SPD', '${gps.speedKmh.toStringAsFixed(0)} km/h'),
      ],
    );
  }

  Widget _buildEnginePanel(DebugEngineState engine) {
    final queuePct = engine.maxQueueDepth > 0
        ? engine.queueDepth / engine.maxQueueDepth
        : 0.0;
    final queueColor = queuePct > 0.75
        ? AppColors.error
        : queuePct > 0.5
        ? AppColors.warning
        : AppColors.success;

    return _Panel(
      label: 'ENGINE',
      children: [
        _Row(
          'QUEUE',
          '${engine.queueDepth}/${engine.maxQueueDepth}',
          color: queueColor,
        ),
        _Row('COOL', '${engine.activeCooldowns.length} active'),
      ],
    );
  }

  Widget _buildCueCounters(DebugEngineState engine) {
    return _Panel(
      label: 'CUES',
      children: [
        _Row('EMIT/L', '${engine.cuesEmittedLap}'),
        _Row('FILT/L', '${engine.cuesFilteredLap}'),
        _Row('EMIT/S', '${engine.cuesEmittedSession}'),
        _Row('FILT/S', '${engine.cuesFilteredSession}'),
      ],
    );
  }

  Widget _buildFramePanel(rust.FrameOutput? frame) {
    if (frame == null) {
      return _Panel(
        label: 'FRAME',
        children: [_Row('STATUS', 'NO DATA', color: AppColors.textDisabled)],
      );
    }

    final deltaColor = frame.deltaTSeconds < 0
        ? AppColors.deltaFaster
        : frame.deltaTSeconds > 0
        ? AppColors.deltaSlower
        : AppColors.deltaNeutral;

    return _Panel(
      label: 'FRAME',
      children: [
        _Row(
          'Δt',
          '${frame.deltaTSeconds >= 0 ? "+" : ""}${frame.deltaTSeconds.toStringAsFixed(2)}s',
          color: deltaColor,
        ),
        _Row('GRIP', '${(frame.gripUtilization * 100).toStringAsFixed(0)}%'),
        _Row('DIST', '${frame.trackDistanceM.toStringAsFixed(0)}m'),
        _Row('SEC', '${frame.currentSector}'),
      ],
    );
  }
}

// =============================================================================
// Shared sub-widgets
// =============================================================================

/// A small panel with a label header and key-value rows.
class _Panel extends StatelessWidget {
  const _Panel({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        ...children,
      ],
    );
  }
}

/// A single key → value row in a debug panel.
class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textDisabled,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny animated status dot.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.success : AppColors.textDisabled,
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
    );
  }
}
