import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/core/router/app_router.dart';
import 'package:race_coach/features/racebox/data/racebox_service.dart';
import 'package:race_coach/features/racebox/data/racebox_providers.dart';

/// Shows a modal bottom sheet for managing the connected RaceBox device.
void showDeviceBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final deviceId = ref.watch(connectedDeviceIdProvider);
        final isConnected = deviceId != null;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ──────────────────────────────────────
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDim,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Header ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    isConnected ? 'Connected Device' : 'No Device',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (isConnected) ...[
                  // ── Device name ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bluetooth_connected,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'RaceBox Mini',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Status row ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final data = ref.watch(raceBoxDataProvider);
                        return Row(
                          children: [
                            _StatusChip(
                              icon: Icons.satellite_alt,
                              label: '${data.satellites} sats',
                            ),
                            const SizedBox(width: 12),
                            const _StatusChip(
                              icon: Icons.speed,
                              label: '25 Hz',
                            ),
                            const SizedBox(width: 12),
                            _StatusChip(
                              icon: Icons.signal_cellular_alt,
                              label: data.satellites >= 8
                                  ? 'Excellent'
                                  : data.satellites >= 5
                                  ? 'Good'
                                  : 'Weak',
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Divider(color: AppColors.divider),
                  ),

                  // ── Disconnect ───────────────────────────────────
                  ListTile(
                    leading: const Icon(
                      Icons.bluetooth_disabled,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Disconnect',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      final service = ref.read(raceBoxServiceProvider);
                      service.disconnect();
                      ref.read(connectedDeviceIdProvider.notifier).state = null;
                      Navigator.of(context).pop();
                    },
                  ),

                  // ── Find other devices ───────────────────────────
                  ListTile(
                    leading: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      'Find Other Devices',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.deviceScanner);
                    },
                  ),
                ] else ...[
                  // ── Disconnected state ───────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'No device connected',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.bluetooth,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Connect Device',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(AppRoutes.deviceScanner);
                    },
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Small chip widget for displaying a status metric.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
