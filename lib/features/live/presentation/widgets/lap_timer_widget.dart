import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';

// ── Lap State ──────────────────────────────────────────────────────────

/// Immutable state for the lap timer.
class LapTimerState {
  const LapTimerState({
    this.currentLapTime = Duration.zero,
    this.bestLapTime,
    this.lapCount = 0,
    this.delta = Duration.zero,
    this.isRunning = false,
  });

  /// Elapsed time of the current lap.
  final Duration currentLapTime;

  /// Best lap time recorded this session (null if no lap completed).
  final Duration? bestLapTime;

  /// Number of completed laps.
  final int lapCount;

  /// Delta to best lap (positive = slower, negative = faster).
  final Duration delta;

  /// Whether the timer is actively counting.
  final bool isRunning;

  LapTimerState copyWith({
    Duration? currentLapTime,
    Duration? bestLapTime,
    int? lapCount,
    Duration? delta,
    bool? isRunning,
    bool clearBest = false,
  }) {
    return LapTimerState(
      currentLapTime: currentLapTime ?? this.currentLapTime,
      bestLapTime: clearBest ? null : (bestLapTime ?? this.bestLapTime),
      lapCount: lapCount ?? this.lapCount,
      delta: delta ?? this.delta,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

// ── State Notifier ─────────────────────────────────────────────────────

class LapTimerNotifier extends StateNotifier<LapTimerState> {
  LapTimerNotifier() : super(const LapTimerState());

  Timer? _timer;
  DateTime? _lapStartTime;

  /// Start / resume the lap timer.
  void start() {
    if (state.isRunning) return;

    _lapStartTime = DateTime.now();
    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_lapStartTime == null) return;
      final elapsed = DateTime.now().difference(_lapStartTime!);
      final delta = state.bestLapTime != null
          ? elapsed - state.bestLapTime!
          : Duration.zero;

      state = state.copyWith(currentLapTime: elapsed, delta: delta);
    });
  }

  /// Record a completed lap and restart the timer.
  void completeLap() {
    if (!state.isRunning || _lapStartTime == null) return;

    final lapTime = DateTime.now().difference(_lapStartTime!);
    final newLapCount = state.lapCount + 1;

    Duration? newBest = state.bestLapTime;
    if (newBest == null || lapTime < newBest) {
      newBest = lapTime;
    }

    state = LapTimerState(
      currentLapTime: Duration.zero,
      bestLapTime: newBest,
      lapCount: newLapCount,
      delta: Duration.zero,
      isRunning: true,
    );

    _lapStartTime = DateTime.now();
  }

  /// Stop the timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  /// Reset everything.
  void reset() {
    _timer?.cancel();
    _timer = null;
    _lapStartTime = null;
    state = const LapTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ── Provider ───────────────────────────────────────────────────────────

final lapTimerProvider = StateNotifierProvider<LapTimerNotifier, LapTimerState>(
  (ref) {
    return LapTimerNotifier();
  },
);

// ── Widget ─────────────────────────────────────────────────────────────

/// Lap timer display showing current lap time, best lap, delta, and lap count.
class LapTimerWidget extends ConsumerWidget {
  const LapTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lapState = ref.watch(lapTimerProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lapState.lapCount == 0 ? 'LAP –' : 'LAP ${lapState.lapCount}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              Icon(
                lapState.isRunning
                    ? Icons.timer_rounded
                    : Icons.timer_off_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Current lap time ────────────────────────────────────
          Text(
            _formatDuration(lapState.currentLapTime),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: lapState.isRunning
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 6),

          // ── Delta ──────────────────────────────────────────────
          if (lapState.bestLapTime != null && lapState.isRunning)
            _DeltaDisplay(delta: lapState.delta),

          const SizedBox(height: 6),

          // ── Best lap ────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                lapState.bestLapTime != null
                    ? 'BEST ${_formatDuration(lapState.bestLapTime!)}'
                    : 'BEST --:--.---',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$millis';
  }
}

class _DeltaDisplay extends StatelessWidget {
  const _DeltaDisplay({required this.delta});

  final Duration delta;

  @override
  Widget build(BuildContext context) {
    final isPositive = delta.inMilliseconds >= 0;
    final color = isPositive ? AppColors.deltaSlower : AppColors.deltaFaster;
    final prefix = isPositive ? '+' : '-';
    final absDelta = delta.abs();
    final seconds = absDelta.inMilliseconds / 1000.0;

    return Text(
      '$prefix${seconds.toStringAsFixed(2)}s',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
