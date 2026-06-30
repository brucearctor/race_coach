import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/coaching/data/reference_lap_service.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';

/// Compact horizontal sector split bar showing S1, S2, S3 deltas.
///
/// Features:
/// - Chips for each sector: current (bright), completed (delta-colored), future (dim)
/// - Delta text: '+0.3' (red / slower) or '-0.2' (green / faster)
/// - Thin lap-progress gradient bar underneath
/// - Auto-resets accumulated deltas when currentSector returns to 1
/// - Graceful fallback when no reference lap is available
class SectorBarWidget extends ConsumerStatefulWidget {
  const SectorBarWidget({super.key});

  @override
  ConsumerState<SectorBarWidget> createState() => _SectorBarWidgetState();
}

class _SectorBarWidgetState extends ConsumerState<SectorBarWidget> {
  /// Accumulated sector deltas for completed sectors (1-indexed).
  /// Key = sector number, Value = delta in seconds.
  final Map<int, double> _completedDeltas = {};

  /// Track the previous sector to detect transitions.
  int _previousSector = 0;

  /// Last known delta for the sector we're currently in.
  /// Captured continuously so we have the correct value on transition.
  double? _lastKnownDelta;

  static const int _totalSectors = 3;

  @override
  Widget build(BuildContext context) {
    final frameOutput = ref.watch(rustFrameOutputProvider);
    final hasReference = ref.watch(hasReferenceLapProvider);

    final currentSector = frameOutput?.currentSector ?? 1;
    final sectorDelta = frameOutput?.sectorDelta;
    final lapProgress = frameOutput?.lapDistancePct ?? 0.0;

    // Detect lap reset: sector went back to 1.
    if (currentSector == 1 && _previousSector > 1) {
      // Store the last sector delta before resetting.
      if (_previousSector <= _totalSectors && _lastKnownDelta != null) {
        _completedDeltas[_previousSector] = _lastKnownDelta!;
      }
      _completedDeltas.clear();
      _lastKnownDelta = null;
    }

    // Detect sector transition: store delta for the sector we just left.
    if (currentSector > _previousSector && _previousSector > 0) {
      if (_lastKnownDelta != null) {
        _completedDeltas[_previousSector] = _lastKnownDelta!;
      }
      _lastKnownDelta = null;
    }

    // Continuously track the current sector's delta.
    if (sectorDelta != null) {
      _lastKnownDelta = sectorDelta;
    }

    _previousSector = currentSector;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sector chips row.
          Row(
            children: List.generate(_totalSectors, (index) {
              final sectorNum = index + 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index > 0 ? 4 : 0,
                  ),
                  child: _buildSectorChip(
                    sectorNum: sectorNum,
                    currentSector: currentSector,
                    liveDelta: sectorDelta,
                    hasReference: hasReference,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 6),

          // Lap progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: lapProgress.clamp(0.0, 1.0),
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorChip({
    required int sectorNum,
    required int currentSector,
    required double? liveDelta,
    required bool hasReference,
  }) {
    final isCurrent = sectorNum == currentSector;
    final isCompleted = sectorNum < currentSector;

    // Determine the delta value and color.
    double? delta;
    Color chipBackground;
    Color textColor;

    if (isCompleted && _completedDeltas.containsKey(sectorNum)) {
      delta = _completedDeltas[sectorNum];
      chipBackground = delta != null && delta < 0
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.accent.withValues(alpha: 0.2);
      textColor = AppColors.textPrimary;
    } else if (isCurrent) {
      delta = hasReference ? liveDelta : null;
      chipBackground = AppColors.primaryMuted.withValues(alpha: 0.3);
      textColor = AppColors.textPrimary;
    } else {
      // Future sector.
      chipBackground = AppColors.divider.withValues(alpha: 0.3);
      textColor = AppColors.textDisabled;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipBackground,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 0.5,
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'S$sectorNum',
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          if (delta != null && hasReference) ...[
            const SizedBox(width: 4),
            Text(
              _formatDelta(delta),
              style: TextStyle(
                color: delta < 0 ? AppColors.deltaFaster : AppColors.deltaSlower,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Format a delta value for display (e.g., '+0.3', '-0.2').
  String _formatDelta(double delta) {
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)}';
  }
}
