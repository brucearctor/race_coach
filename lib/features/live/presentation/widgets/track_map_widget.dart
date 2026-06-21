

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:race_coach/core/theme/app_colors.dart';
import 'package:race_coach/features/racebox/data/racebox_providers.dart';
import 'package:race_coach/features/racebox/domain/racebox_data.dart';

// ── Track Point ────────────────────────────────────────────────────────

/// A single GPS breadcrumb with associated speed for color-coding.
class TrackPoint {
  const TrackPoint({
    required this.position,
    required this.speedMph,
    required this.timestamp,
  });

  final LatLng position;
  final double speedMph;
  final DateTime timestamp;
}

// ── State Notifier ─────────────────────────────────────────────────────

/// Accumulates GPS track points from telemetry updates.
class TrackMapNotifier extends StateNotifier<List<TrackPoint>> {
  TrackMapNotifier() : super([]);

  static const int maxPoints = 5000;

  /// Add a new telemetry sample to the track.
  void addPoint(RaceBoxData data) {
    if (!data.hasValidFix) return;

    final point = TrackPoint(
      position: LatLng(data.latitude, data.longitude),
      speedMph: data.speedMph,
      timestamp: data.timestamp,
    );

    final newList = [...state, point];

    // Trim to max points, keeping the most recent.
    if (newList.length > maxPoints) {
      state = newList.sublist(newList.length - maxPoints);
    } else {
      state = newList;
    }
  }

  /// Clear all recorded points.
  void clear() => state = [];
}

// ── Providers ──────────────────────────────────────────────────────────

final trackMapProvider =
    StateNotifierProvider<TrackMapNotifier, List<TrackPoint>>((ref) {
  return TrackMapNotifier();
});

// ── Widget ─────────────────────────────────────────────────────────────

/// GPS trail map showing the driver's path color-coded by speed.
///
/// Uses flutter_map with OpenStreetMap tiles. The current position is
/// shown as a pulsing blue dot. When no GPS data is available, a
/// "Waiting for GPS…" placeholder is displayed.
class TrackMapWidget extends ConsumerStatefulWidget {
  const TrackMapWidget({super.key});

  @override
  ConsumerState<TrackMapWidget> createState() => _TrackMapWidgetState();
}

class _TrackMapWidgetState extends ConsumerState<TrackMapWidget>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 8, end: 16).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackPoints = ref.watch(trackMapProvider);
    final raceBoxData = ref.watch(raceBoxDataProvider);

    // No GPS data yet.
    if (trackPoints.isEmpty || !raceBoxData.hasValidFix) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.satellite_alt_rounded,
                size: 32,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 8),
              Text(
                'Waiting for GPS…',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentPosition =
        LatLng(raceBoxData.latitude, raceBoxData.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: currentPosition,
          initialZoom: 16.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          // ── Map tiles ─────────────────────────────────────────
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.race_coach',
          ),

          // ── Speed-coded polyline trail ─────────────────────────
          if (trackPoints.length >= 2)
            PolylineLayer(
              polylines: _buildSpeedPolylines(trackPoints),
            ),

          // ── Current position marker ────────────────────────────
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition,
                    width: _pulseAnimation.value * 2,
                    height: _pulseAnimation.value * 2,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.3),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build polyline segments color-coded by speed.
  ///
  /// Uses HSL interpolation: red (hue=0) for slow → green (hue=120) for fast.
  List<Polyline> _buildSpeedPolylines(List<TrackPoint> points) {
    if (points.length < 2) return [];

    // Find speed range for normalisation.
    double minSpeed = double.infinity;
    double maxSpeed = 0;
    for (final p in points) {
      if (p.speedMph < minSpeed) minSpeed = p.speedMph;
      if (p.speedMph > maxSpeed) maxSpeed = p.speedMph;
    }

    final speedRange = maxSpeed - minSpeed;
    if (speedRange < 1) {
      // All roughly the same speed — draw single-colour line.
      return [
        Polyline(
          points: points.map((p) => p.position).toList(),
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ];
    }

    // Build a polyline per segment so each can have its own colour.
    final polylines = <Polyline>[];
    for (int i = 0; i < points.length - 1; i++) {
      final avgSpeed = (points[i].speedMph + points[i + 1].speedMph) / 2;
      final normalised = ((avgSpeed - minSpeed) / speedRange).clamp(0.0, 1.0);

      // Hue: 0 (red) for slow → 120 (green) for fast.
      final hue = normalised * 120;
      final color = HSLColor.fromAHSL(1.0, hue, 0.9, 0.5).toColor();

      polylines.add(Polyline(
        points: [points[i].position, points[i + 1].position],
        color: color,
        strokeWidth: 3,
      ));
    }

    return polylines;
  }
}
