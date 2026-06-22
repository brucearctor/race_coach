import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';

/// 2D circular g-force display showing lateral (X) vs longitudinal (Y) forces.
///
/// Features:
/// - Concentric circles at 0.5g intervals
/// - Moving dot at current g position
/// - Trail of recent positions (last ~20 points, fading)
/// - Axis labels (Brake/Accel/Left/Right)
/// - Color-coded dot based on total g magnitude
class GForceWidget extends ConsumerStatefulWidget {
  const GForceWidget({super.key});

  @override
  ConsumerState<GForceWidget> createState() => _GForceWidgetState();
}

class _GForceWidgetState extends ConsumerState<GForceWidget> {
  /// Trail of recent g-force readings: (lateralG, longitudinalG).
  final List<(double, double)> _trail = [];
  static const int _maxTrailLength = 20;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final telemetryState = ref.watch(telemetryBusProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _GForcePainter(
                lateralG: telemetryState.lateralG,
                longitudinalG: telemetryState.longitudinalG,
                trail: List.from(_trail),
                maxG: 2.0,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GForcePainter extends CustomPainter {
  _GForcePainter({
    required this.lateralG,
    required this.longitudinalG,
    required this.trail,
    required this.maxG,
  });

  final double lateralG;
  final double longitudinalG;
  final List<(double, double)> trail;
  final double maxG;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    _drawGrid(canvas, center, radius, size);
    _drawAxisLabels(canvas, center, radius, size);
    _drawTrail(canvas, center, radius);
    _drawCurrentDot(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Concentric circles at 0.5g intervals.
    final intervals = (maxG / 0.5).ceil();
    for (int i = 1; i <= intervals; i++) {
      final r = (i * 0.5 / maxG) * radius;
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

  void _drawAxisLabels(
      Canvas canvas, Offset center, double radius, Size size) {
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    // Top: Accel
    _drawText(canvas, 'ACCEL', Offset(center.dx, center.dy - radius - 14),
        style, TextAlign.center);

    // Bottom: Brake
    _drawText(canvas, 'BRAKE', Offset(center.dx, center.dy + radius + 4),
        style, TextAlign.center);

    // Left: Left
    _drawText(canvas, 'L', Offset(center.dx - radius - 10, center.dy - 5),
        style, TextAlign.center);

    // Right: Right
    _drawText(canvas, 'R', Offset(center.dx + radius + 4, center.dy - 5),
        style, TextAlign.center);
  }

  void _drawTrail(Canvas canvas, Offset center, double radius) {
    if (trail.isEmpty) return;

    for (int i = 0; i < trail.length; i++) {
      final (latG, lonG) = trail[i];
      final offset = _gToOffset(latG, lonG, center, radius);
      final alpha = (i + 1) / trail.length * 0.6;
      final trailPaint = Paint()
        ..color = _colorForG(
          math.sqrt(latG * latG + lonG * lonG),
        ).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, 2.5, trailPaint);
    }
  }

  void _drawCurrentDot(Canvas canvas, Offset center, double radius) {
    final offset = _gToOffset(lateralG, longitudinalG, center, radius);
    final totalG = math.sqrt(lateralG * lateralG + longitudinalG * longitudinalG);
    final color = _colorForG(totalG);

    // Outer glow.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(offset, 8, glowPaint);

    // Solid dot.
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 5, dotPaint);

    // White center.
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 1.5, centerPaint);
  }

  /// Convert g-force values to a canvas offset.
  ///
  /// lateralG:      positive = right → positive X offset
  /// longitudinalG: positive = accel → negative Y offset (up on screen)
  Offset _gToOffset(
      double latG, double lonG, Offset center, double radius) {
    final clampedLat = latG.clamp(-maxG, maxG);
    final clampedLon = lonG.clamp(-maxG, maxG);

    final x = center.dx + (clampedLat / maxG) * radius;
    final y = center.dy - (clampedLon / maxG) * radius;
    return Offset(x, y);
  }

  /// Color based on total g-force magnitude.
  Color _colorForG(double g) {
    if (g < 0.5) return AppColors.gForceIdle;
    if (g < 1.0) return AppColors.gForceModerate;
    if (g < 1.5) return AppColors.gForceHigh;
    return AppColors.gForceExtreme;
  }

  void _drawText(Canvas canvas, String text, Offset position,
      TextStyle style, TextAlign align) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: align,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final offset = Offset(
      position.dx - textPainter.width / 2,
      position.dy,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _GForcePainter oldDelegate) {
    return lateralG != oldDelegate.lateralG ||
        longitudinalG != oldDelegate.longitudinalG ||
        trail.length != oldDelegate.trail.length;
  }
}
