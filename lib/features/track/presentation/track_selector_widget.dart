import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/generated/racecoach/v1/track.pb.dart';
import 'package:race_coach/features/track/data/track_service.dart';

// =============================================================================
// Track Selector Widget — shows current track + config, allows changes
// =============================================================================

/// Compact track-selection widget for use in the settings screen.
///
/// Displays:
/// - Current track name + configuration name (or "No track detected")
/// - An "Auto-detected" badge when the track was found via GPS proximity
/// - Dropdown selectors for manually choosing a track and layout
class TrackSelectorWidget extends ConsumerWidget {
  const TrackSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackState = ref.watch(trackServiceProvider);
    final notifier = ref.read(trackServiceProvider.notifier);

    final selectedTrack = trackState.selectedTrack;
    final selectedConfig = trackState.selectedConfig;
    final availableTracks = trackState.availableTracks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Current selection summary ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(
                selectedTrack != null
                    ? Icons.location_on_rounded
                    : Icons.location_off_rounded,
                color: selectedTrack != null
                    ? AppColors.success
                    : AppColors.textDisabled,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedTrack?.name ?? 'No track detected',
                      style: TextStyle(
                        color: selectedTrack != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (selectedConfig != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          selectedConfig.name,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trackState.autoDetected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'AUTO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Track dropdown ─────────────────────────────────────────────
        _buildDropdownLabel('Track'),
        const SizedBox(height: 4),
        _buildTrackDropdown(
          availableTracks: availableTracks,
          selectedTrack: selectedTrack,
          onChanged: (track) {
            if (track != null && track.configurations.isNotEmpty) {
              notifier.selectTrack(track, track.configurations.first);
            }
          },
        ),

        const SizedBox(height: 12),

        // ── Configuration dropdown ─────────────────────────────────────
        if (selectedTrack != null &&
            selectedTrack.configurations.length > 1) ...[
          _buildDropdownLabel('Layout'),
          const SizedBox(height: 4),
          _buildConfigDropdown(
            configurations: selectedTrack.configurations,
            selectedConfig: selectedConfig,
            onChanged: (config) {
              if (config != null) {
                notifier.selectTrack(selectedTrack, config);
              }
            },
          ),
        ],

        // ── Clear button ───────────────────────────────────────────────
        if (selectedTrack != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => notifier.clearSelection(),
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildDropdownLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTrackDropdown({
    required List<Track> availableTracks,
    required Track? selectedTrack,
    required ValueChanged<Track?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: DropdownButton<String>(
        value: selectedTrack?.trackId,
        hint: const Text(
          'Select a track…',
          style: TextStyle(color: AppColors.textHint, fontSize: 14),
        ),
        isExpanded: true,
        dropdownColor: AppColors.surface,
        underline: const SizedBox.shrink(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        items: availableTracks.map((track) {
          return DropdownMenuItem<String>(
            value: track.trackId,
            child: Text(
              '${track.name} (${track.region})',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (trackId) {
          final track = availableTracks.firstWhere(
            (t) => t.trackId == trackId,
          );
          onChanged(track);
        },
      ),
    );
  }

  Widget _buildConfigDropdown({
    required List<TrackConfiguration> configurations,
    required TrackConfiguration? selectedConfig,
    required ValueChanged<TrackConfiguration?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: DropdownButton<String>(
        value: selectedConfig?.configId,
        isExpanded: true,
        dropdownColor: AppColors.surface,
        underline: const SizedBox.shrink(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        items: configurations.map((config) {
          final hasFinish = config.hasFinishLineA() && config.hasFinishLineB();
          return DropdownMenuItem<String>(
            value: config.configId,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    config.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasFinish)
                  const Icon(Icons.flag_rounded,
                      size: 14, color: AppColors.success),
              ],
            ),
          );
        }).toList(),
        onChanged: (configId) {
          final config = configurations.firstWhere(
            (c) => c.configId == configId,
          );
          onChanged(config);
        },
      ),
    );
  }
}
