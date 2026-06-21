import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';

/// Large, prominent speed readout with color-coded display.
///
/// Color shifts based on speed:
/// - Green:  < 60 mph
/// - Yellow: 60–120 mph
/// - Red:    > 120 mph
///
/// Includes a subtle glow behind the number and a max-speed indicator.
class SpeedDisplay extends ConsumerStatefulWidget {
  const SpeedDisplay({super.key});

  @override
  ConsumerState<SpeedDisplay> createState() => _SpeedDisplayState();
}

class _SpeedDisplayState extends ConsumerState<SpeedDisplay> {
  double _maxSpeed = 0;

  @override
  Widget build(BuildContext context) {
    final telemetryState = ref.watch(telemetryBusProvider);
    final speedMph = telemetryState.speedMph;
    final speedInt = speedMph.round();

    // Track maximum speed in session.
    if (speedMph > _maxSpeed) {
      _maxSpeed = speedMph;
    }

    final speedColor = _colorForSpeed(speedMph);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Main speed number with glow ────────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow layer
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$speedInt',
                  key: ValueKey<int>(speedInt),
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w800,
                    color: speedColor.withValues(alpha: 0.15),
                    letterSpacing: -2,
                  ),
                ),
              ),
              // Foreground speed
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  '$speedInt',
                  key: ValueKey<int>(speedInt),
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w800,
                    color: speedColor,
                    letterSpacing: -2,
                    shadows: [
                      Shadow(
                        color: speedColor.withValues(alpha: 0.6),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Unit label ────────────────────────────────────────────
          Text(
            'MPH',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 8),

          // ── Max speed indicator ────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'MAX ${_maxSpeed.round()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns a color based on the current speed in mph.
  Color _colorForSpeed(double mph) {
    if (mph < 60) return AppColors.success;
    if (mph <= 120) return AppColors.warning;
    return AppColors.error;
  }
}
