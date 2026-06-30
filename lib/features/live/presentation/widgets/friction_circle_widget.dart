import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/coaching/data/rust_bridge_provider.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';

/// Real-time friction circle visualisation (2D g-g diagram).
///
/// Features:
/// - Concentric circles at 0.5g intervals
/// - Outer limit circle sized to [FrictionCircleState.gMax]
/// - Moving dot at current (lateralG, longitudinalG) position
/// - Trail of last 25 readings with fading opacity
/// - Dot color coded by grip utilization percentage
/// - Utilization readout ('78% grip') at bottom
/// - State labels: 'TB' (trail braking) / 'C' (coasting) at top-left
/// - Axis labels: B (top), A (bottom), L (left), R (right)
class FrictionCircleWidget extends ConsumerStatefulWidget {
  const FrictionCircleWidget({super.key});

  @override
  ConsumerState<FrictionCircleWidget> createState() =>
      _FrictionCircleWidgetState();
}

class _FrictionCircleWidgetState extends ConsumerState<FrictionCircleWidget>
    with SingleTickerProviderStateMixin {
  /// Trail of recent g-force readings: (lateralG, longitudinalG).
  final List<(double, double)> _trail = [];
  static const int _maxTrailLength = 25;

  /// Animation controller for the >100% utilization pulse effect.
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(telemetryBusProvider, (previous, next) {
        _trail.add((next.lateralG, next.longitudinalG));
        if (_trail.length > _maxTrailLength) {
          _trail.removeAt(0);
        }
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryBusProvider);
    final frameOutput = ref.watch(rustFrameOutputProvider);
    final frictionCircle = frameOutput?.frictionCircle;

    final utilization = frictionCircle?.utilization ?? 0.0;
    final gMax = frictionCircle?.gMax ?? 1.5;
    final isTrailBraking = frictionCircle?.isTrailBraking ?? false;
    final isCoasting = frictionCircle?.isCoasting ?? false;

    // Only run the pulse animation when over the tire limit.
    if (utilization > 1.0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (utilization <= 1.0 && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row with status labels.
          _buildTitleRow(isTrailBraking, isCoasting),
          const SizedBox(height: 4),

          // Main g-g diagram.
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        painter: _FrictionCirclePainter(
                          lateralG: telemetry.lateralG,
                          longitudinalG: telemetry.longitudinalG,
                          trail: List.from(_trail),
                          gMax: gMax,
                          utilization: utilization,
                          pulseValue: _pulseAnimation.value,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Utilization readout.
          Text(
            '${(utilization * 100).round()}% grip',
            style: TextStyle(
              color: _utilizationColor(utilization),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(bool isTrailBraking, bool isCoasting) {
    return Stack(
      children: [
        // Status labels at top-left.
        if (isTrailBraking)
          const Positioned(
            left: 0,
            child: Text(
              'TB',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          )
        else if (isCoasting)
          Positioned(
            left: 0,
            child: Text(
              'C',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),

        // Title centered.
        const Center(
          child: Text(
            'FRICTION',
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  /// Color based on grip utilization percentage.
  Color _utilizationColor(double utilization) {
    if (utilization < 0.5) return AppColors.success;
    if (utilization < 0.8) return AppColors.warning;
    if (utilization <= 1.0) return AppColors.accent;
    return AppColors.accent; // >100% — pulsing handled by painter
  }
}

// =============================================================================
// Painter
// =============================================================================

class _FrictionCirclePainter extends CustomPainter {
  _FrictionCirclePainter({
    required this.lateralG,
    required this.longitudinalG,
    required this.trail,
    required this.gMax,
    required this.utilization,
    required this.pulseValue,
  });

  final double lateralG;
  final double longitudinalG;
  final List<(double, double)> trail;
  final double gMax;
  final double utilization;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    _drawGrid(canvas, center, radius);
    _drawLimitCircle(canvas, center, radius);
    _drawAxisLabels(canvas, center, radius);
    _drawTrail(canvas, center, radius);
    _drawCurrentDot(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Concentric circles at 0.5g intervals.
    final intervals = (gMax / 0.5).ceil();
    for (int i = 1; i <= intervals; i++) {
      final r = (i * 0.5 / gMax) * radius;
      canvas.drawCircle(center, r, gridPaint);
    }

    // Cross-hair axes.
    final axisPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.8)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axisPaint,
    );
  }

  void _drawLimitCircle(Canvas canvas, Offset center, double radius) {
    final limitPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // The outer limit circle is at gMax, which maps to the full radius.
    canvas.drawCircle(center, radius, limitPaint);
  }

  void _drawAxisLabels(Canvas canvas, Offset center, double radius) {
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    // Top: Brake (positive longitudinalG maps upward in racing convention).
    _drawText(
      canvas,
      'B',
      Offset(center.dx, center.dy - radius - 14),
      style,
    );

    // Bottom: Accel.
    _drawText(
      canvas,
      'A',
      Offset(center.dx, center.dy + radius + 4),
      style,
    );

    // Left.
    _drawText(
      canvas,
      'L',
      Offset(center.dx - radius - 10, center.dy - 5),
      style,
    );

    // Right.
    _drawText(
      canvas,
      'R',
      Offset(center.dx + radius + 4, center.dy - 5),
      style,
    );
  }

  void _drawTrail(Canvas canvas, Offset center, double radius) {
    if (trail.isEmpty) return;

    for (int i = 0; i < trail.length; i++) {
      final (latG, lonG) = trail[i];
      final offset = _gToOffset(latG, lonG, center, radius);
      final alpha = (i + 1) / trail.length * 0.5;
      final trailPaint = Paint()
        ..color = _dotColor(utilization).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, 2.0, trailPaint);
    }
  }

  void _drawCurrentDot(Canvas canvas, Offset center, double radius) {
    final offset = _gToOffset(lateralG, longitudinalG, center, radius);
    final color = _dotColor(utilization);

    // Apply pulse for >100% utilization.
    final effectiveAlpha = utilization > 1.0 ? pulseValue : 1.0;

    // Outer glow.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * effectiveAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(offset, 10, glowPaint);

    // Solid dot.
    final dotPaint = Paint()
      ..color = color.withValues(alpha: effectiveAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 5, dotPaint);

    // White center.
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: effectiveAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 1.5, centerPaint);
  }

  /// Convert g-force values to a canvas offset.
  ///
  /// lateralG:      positive = right → positive X offset
  /// longitudinalG: positive = accel → negative Y offset (up on screen)
  Offset _gToOffset(double latG, double lonG, Offset center, double radius) {
    final clampedLat = latG.clamp(-gMax, gMax);
    final clampedLon = lonG.clamp(-gMax, gMax);

    final x = center.dx + (clampedLat / gMax) * radius;
    final y = center.dy - (clampedLon / gMax) * radius;
    return Offset(x, y);
  }

  /// Dot color based on grip utilization percentage.
  Color _dotColor(double utilization) {
    if (utilization < 0.5) return AppColors.success;
    if (utilization < 0.8) return AppColors.warning;
    if (utilization <= 1.0) return AppColors.accent;
    // >100%: bright red (pulsing handled by effectiveAlpha).
    return const Color(0xFFFF4444);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style,
  ) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final offset = Offset(position.dx - textPainter.width / 2, position.dy);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _FrictionCirclePainter oldDelegate) {
    return lateralG != oldDelegate.lateralG ||
        longitudinalG != oldDelegate.longitudinalG ||
        gMax != oldDelegate.gMax ||
        utilization != oldDelegate.utilization ||
        pulseValue != oldDelegate.pulseValue ||
        trail.length != oldDelegate.trail.length ||
        // Once the trail is full, always repaint since the oldest
        // point was removed and a new one added.
        trail.length >= 25;
  }
}
