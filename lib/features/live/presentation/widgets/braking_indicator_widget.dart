import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';

/// Compact braking state pill indicator.
///
/// Features:
/// - Pill shape (~60×28px content area)
/// - Idle state: dim outline with 'BRAKE' in muted text
/// - Active state: red background with 'BRAKE' in white/bold
/// - Background intensity proportional to braking G magnitude
/// - Optional onset delta subtitle ('+3m' green / '-5m' red)
/// - 150ms animated transitions between states
class BrakingIndicatorWidget extends ConsumerWidget {
  const BrakingIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frameOutput = ref.watch(rustFrameOutputProvider);
    final brakingState = frameOutput?.brakingState;

    final isBraking = brakingState?.isBraking ?? false;
    final brakingG = brakingState?.brakingG ?? 0.0;
    final referenceOnsetDeltaM = brakingState?.referenceOnsetDeltaM;

    // Scale background opacity by braking G magnitude (0 → 1.0g+ range).
    final intensity = isBraking
        ? (brakingG.abs() / 1.0).clamp(0.3, 1.0)
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minWidth: 60),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isBraking
            ? AppColors.accent.withValues(alpha: intensity)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBraking
              ? AppColors.accent
              : AppColors.divider,
          width: isBraking ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary label.
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              color: isBraking ? Colors.white : AppColors.textDim,
              fontSize: 11,
              fontWeight: isBraking ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 1.0,
            ),
            child: const Text('BRAKE'),
          ),

          // Onset delta subtitle.
          if (isBraking && referenceOnsetDeltaM != null)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                _formatOnsetDelta(referenceOnsetDeltaM),
                style: TextStyle(
                  color: referenceOnsetDeltaM >= 0
                      ? AppColors.deltaSlower
                      : AppColors.deltaFaster,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Format onset delta in meters (e.g., '+3m', '-5m').
  String _formatOnsetDelta(double deltaM) {
    final sign = deltaM >= 0 ? '+' : '';
    return '$sign${deltaM.round()}m';
  }
}
