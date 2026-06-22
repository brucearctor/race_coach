import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/core/permissions/permission_service.dart';
import 'package:race_coach/features/ble/data/ble_service.dart';
import 'package:race_coach/features/ble/domain/ble_device.dart';
import 'package:race_coach/features/racebox/data/racebox_service.dart';
import 'package:race_coach/core/router/app_router.dart';

/// Screen that scans for nearby BLE devices and lets the user connect
/// to a RaceBox Mini.
class DeviceScannerScreen extends ConsumerStatefulWidget {
  const DeviceScannerScreen({super.key});

  @override
  ConsumerState<DeviceScannerScreen> createState() =>
      _DeviceScannerScreenState();
}

class _DeviceScannerScreenState extends ConsumerState<DeviceScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanAnimationController;
  bool _isScanning = false;
  bool _hasRequestedPermissions = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Actions
  // -----------------------------------------------------------------------

  Future<void> _startScan() async {
    // Request permissions on first scan.
    if (!_hasRequestedPermissions) {
      final permService = ref.read(permissionServiceProvider);
      final granted = await permService.requestBlePermissions();
      _hasRequestedPermissions = true;

      if (!granted) {
        setState(() {
          _statusMessage =
              'Bluetooth permissions are required to scan for devices.';
        });
        return;
      }
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for devices…';
    });
    _scanAnimationController.repeat();

    // Invalidate the scan provider to restart scanning.
    ref.invalidate(bleScanProvider);
  }

  void _stopScan() {
    setState(() {
      _isScanning = false;
      _statusMessage = null;
    });
    _scanAnimationController.stop();
    _scanAnimationController.reset();
  }

  Future<void> _connectToDevice(BleDevice device) async {
    _stopScan();

    // Store the connected device ID.
    ref.read(connectedDeviceIdProvider.notifier).state = device.id;

    // Connect the RaceBox service to start streaming data.
    // RaceBoxService manages its own BLE connection internally.
    final raceBoxService = ref.read(raceBoxServiceProvider);
    await raceBoxService.connect(device.id);

    // Navigate to the dashboard.
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scanResult = ref.watch(bleScanProvider);

    // Stop animation when scan finishes.
    scanResult.whenData((_) {
      // Keep scanning indicator alive while data is streaming.
    });

    // Check if the scan stream has completed (error or done).
    if (scanResult.hasError || (!scanResult.isLoading && !scanResult.isRefreshing)) {
      if (_isScanning) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _stopScan());
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: const Text(
          'Connect Device',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status bar
          _buildStatusBar(),

          // Device list
          Expanded(
            child: scanResult.when(
              data: (devices) => _buildDeviceList(devices),
              loading: () => _buildEmptyState('Scanning for devices…'),
              error: (error, _) => _buildEmptyState(
                'Scan error: ${error.toString()}',
                isError: true,
              ),
            ),
          ),
        ],
      ),

      // Scan FAB
      floatingActionButton: _buildScanButton(),
    );
  }

  // -----------------------------------------------------------------------
  // Sub-widgets
  // -----------------------------------------------------------------------

  Widget _buildStatusBar() {
    if (_statusMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surfaceLight,
      child: Row(
        children: [
          if (_isScanning)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          if (_isScanning) const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(List<BleDevice> devices) {
    if (devices.isEmpty) {
      return _buildEmptyState(
        _isScanning ? 'Searching…' : 'No devices found. Tap scan to search.',
      );
    }

    // Sort: RaceBox devices first, then by RSSI (strongest first).
    final sorted = List<BleDevice>.from(devices)
      ..sort((a, b) {
        if (a.isRaceBox && !b.isRaceBox) return -1;
        if (!a.isRaceBox && b.isRaceBox) return 1;
        return b.rssi.compareTo(a.rssi); // Higher RSSI = closer
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sorted.length,
      itemBuilder: (context, index) => _buildDeviceCard(sorted[index]),
    );
  }

  Widget _buildDeviceCard(BleDevice device) {
    final isRaceBox = device.isRaceBox;

    return Card(
      color: isRaceBox ? AppColors.surfaceLight : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRaceBox
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _connectToDevice(device),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Device icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isRaceBox
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.textDim.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isRaceBox ? Icons.speed : Icons.bluetooth,
                  color: isRaceBox ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Name + signal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            device.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight:
                                  isRaceBox ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRaceBox) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RaceBox',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildSignalIndicator(device.signalLevel),
                        const SizedBox(width: 6),
                        Text(
                          '${device.rssi} dBm · ${device.signalQuality}',
                          style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Connect button
              FilledButton.tonal(
                onPressed: () => _connectToDevice(device),
                style: FilledButton.styleFrom(
                  backgroundColor: isRaceBox
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.textDim.withValues(alpha: 0.2),
                  foregroundColor:
                      isRaceBox ? AppColors.primary : AppColors.textSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Connect', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a 4-bar signal strength indicator.
  Widget _buildSignalIndicator(int level) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final isActive = i < level;
        final height = 4.0 + (i * 3.0);
        return Padding(
          padding: const EdgeInsets.only(right: 1.5),
          child: Container(
            width: 3,
            height: height,
            decoration: BoxDecoration(
              color: isActive ? _signalColor(level) : AppColors.textDim,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }

  Color _signalColor(int level) {
    switch (level) {
      case 4:
        return AppColors.signalExcellent;
      case 3:
        return AppColors.signalGood;
      case 2:
        return AppColors.signalFair;
      case 1:
        return AppColors.signalPoor;
      default:
        return AppColors.signalNone;
    }
  }

  Widget _buildEmptyState(String message, {bool isError = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.bluetooth_searching,
              color: isError ? AppColors.error : AppColors.textDim,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isError ? AppColors.error : AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return FloatingActionButton.extended(
      onPressed: _isScanning ? _stopScan : _startScan,
      backgroundColor: _isScanning ? AppColors.error : AppColors.primary,
      foregroundColor: AppColors.background,
      icon: AnimatedBuilder(
        animation: _scanAnimationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _scanAnimationController.value * 2 * 3.14159,
            child: child,
          );
        },
        child: Icon(
          _isScanning ? Icons.stop : Icons.bluetooth_searching,
        ),
      ),
      label: Text(
        _isScanning ? 'Stop' : 'Scan',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
