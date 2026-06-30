import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/ble/data/ble_service.dart';
import 'package:race_coach/features/ble/domain/ble_device.dart';
import 'package:race_coach/features/racebox/data/racebox_service.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';

/// A compact status chip for the AppBar showing RaceBox connection state,
/// satellite count, signal quality, and data update rate.
class RaceBoxStatusWidget extends ConsumerStatefulWidget {
  const RaceBoxStatusWidget({super.key});

  @override
  ConsumerState<RaceBoxStatusWidget> createState() =>
      _RaceBoxStatusWidgetState();
}

class _RaceBoxStatusWidgetState extends ConsumerState<RaceBoxStatusWidget> {
  DateTime? _lastDataTime;
  double _updateRateHz = 0;

  @override
  Widget build(BuildContext context) {
    final deviceId = ref.watch(connectedDeviceIdProvider);
    final connectionState = deviceId != null
        ? ref.watch(bleDeviceStateProvider(deviceId))
        : BleConnectionState.disconnected;
    final raceBoxAsync = ref.watch(raceBoxDataStreamProvider);

    // Calculate update rate when we get new data.
    raceBoxAsync.whenData((data) {
      final now = DateTime.now();
      if (_lastDataTime != null) {
        final delta = now.difference(_lastDataTime!).inMilliseconds;
        if (delta > 0) {
          _updateRateHz = 1000.0 / delta;
        }
      }
      _lastDataTime = now;
    });

    return _buildChip(connectionState, raceBoxAsync);
  }

  Widget _buildChip(
    BleConnectionState connectionState,
    AsyncValue<RaceBoxData> raceBoxAsync,
  ) {
    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    switch (connectionState) {
      case BleConnectionState.connected:
        final data = raceBoxAsync.valueOrNull;
        if (data != null && data.hasValidFix) {
          statusColor = AppColors.success;
          statusIcon = Icons.satellite_alt;
          statusText =
              '${data.satellites} sats · ${_updateRateHz.toStringAsFixed(0)} Hz';
        } else if (data != null) {
          statusColor = AppColors.warning;
          statusIcon = Icons.satellite_alt;
          statusText = '${data.satellites} sats · Acquiring fix';
        } else {
          statusColor = AppColors.warning;
          statusIcon = Icons.satellite_alt;
          statusText = 'Waiting for data';
        }
      case BleConnectionState.connecting:
        statusColor = AppColors.warning;
        statusIcon = Icons.bluetooth_searching;
        statusText = 'Connecting…';
      case BleConnectionState.error:
        statusColor = AppColors.error;
        statusIcon = Icons.error_outline;
        statusText = 'Error';
      case BleConnectionState.disconnected:
        statusColor = AppColors.error;
        statusIcon = Icons.bluetooth_disabled;
        statusText = 'Disconnected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated dot
          _PulsingDot(
            color: statusColor,
            isActive: connectionState == BleConnectionState.connected,
          ),
          const SizedBox(width: 6),

          // Icon
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),

          // Text
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),

          // Signal quality bars when connected
          if (connectionState == BleConnectionState.connected) ...[
            const SizedBox(width: 8),
            _buildSignalBars(raceBoxAsync.valueOrNull),
          ],
        ],
      ),
    );
  }

  /// Mini signal quality bars based on HDOP.
  Widget _buildSignalBars(RaceBoxData? data) {
    final int level;
    if (data == null) {
      level = 0;
    } else if (data.hdop <= 1.0) {
      level = 4; // Excellent
    } else if (data.hdop <= 2.0) {
      level = 3; // Good
    } else if (data.hdop <= 5.0) {
      level = 2; // Fair
    } else if (data.hdop <= 10.0) {
      level = 1; // Poor
    } else {
      level = 0;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final isActive = i < level;
        final height = 4.0 + (i * 2.5);
        return Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Container(
            width: 2.5,
            height: height,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.textDim,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing dot indicator
// ---------------------------------------------------------------------------

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.isActive});

  final Color color;
  final bool isActive;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
          ),
        );
      },
    );
  }
}
