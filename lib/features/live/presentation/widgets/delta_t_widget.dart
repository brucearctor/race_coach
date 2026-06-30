import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/coaching/data/reference_lap_service.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';

/// Displays the delta-T (time difference vs reference lap).
///
/// Shows:
///   +0.35  (red/slower)
///   -0.12  (green/faster)
///   ±0.00  (blue/neutral)
///
/// Collapses to a small "no reference" indicator when no reference
/// lap is loaded.
class DeltaTWidget extends ConsumerWidget {
  const DeltaTWidget({super.key});

  /// Threshold below which the delta is considered neutral.
  static const double _neutralThreshold = 0.05;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRef = ref.watch(hasReferenceLapProvider);
    if (!hasRef) {
      return _buildNoReference();
    }

    final deltaT = ref.watch(deltaTProvider);
    final color = _deltaColor(deltaT);
    final sign = deltaT > _neutralThreshold
        ? '+'
        : deltaT < -_neutralThreshold
            ? ''
            : '±';
    final display = deltaT.abs() < _neutralThreshold
        ? '${sign}0.00'
        : '$sign${deltaT.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'DELTA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            display,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
            ),
          ),
          Text(
            'sec',
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReference() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.compare_arrows, size: 20, color: AppColors.textDisabled),
          SizedBox(height: 4),
          Text(
            'NO REF LAP',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  static Color _deltaColor(double deltaT) {
    if (deltaT > _neutralThreshold) return AppColors.deltaSlower;
    if (deltaT < -_neutralThreshold) return AppColors.deltaFaster;
    return AppColors.deltaNeutral;
  }
}
