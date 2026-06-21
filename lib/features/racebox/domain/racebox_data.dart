import 'dart:math' as math;

/// Parsed telemetry data from a RaceBox Mini GPS device.
class RaceBoxData {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double headingDegrees;
  final double altitudeMeters;
  final double gForceX;
  final double gForceY;
  final double gForceZ;
  final int satellites;
  final double hdop;

  const RaceBoxData({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.headingDegrees,
    required this.altitudeMeters,
    required this.gForceX,
    required this.gForceY,
    required this.gForceZ,
    required this.satellites,
    required this.hdop,
  });

  // -----------------------------------------------------------------------
  // Computed properties
  // -----------------------------------------------------------------------

  /// Whether the GPS fix is reliable (at least 4 satellites).
  bool get hasValidFix => satellites >= 4;

  /// Speed converted to miles per hour.
  double get speedMph => speedKmh * 0.621371;

  /// Combined lateral + longitudinal G-force (ignores vertical).
  double get totalGForce =>
      math.sqrt(gForceX * gForceX + gForceY * gForceY);

  /// Lateral (side-to-side) G-force. Positive = right turn.
  double get lateralG => gForceX;

  /// Longitudinal (fore-aft) G-force. Positive = acceleration.
  double get longitudinalG => gForceY;

  /// Combined 3-axis G-force magnitude.
  double get totalGForce3D =>
      math.sqrt(gForceX * gForceX + gForceY * gForceY + gForceZ * gForceZ);

  // -----------------------------------------------------------------------
  // Factory constructors
  // -----------------------------------------------------------------------

  /// Returns a zeroed-out "empty" data point.
  factory RaceBoxData.empty() => RaceBoxData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
        latitude: 0,
        longitude: 0,
        speedKmh: 0,
        headingDegrees: 0,
        altitudeMeters: 0,
        gForceX: 0,
        gForceY: 0,
        gForceZ: 0,
        satellites: 0,
        hdop: 99.9,
      );

  // -----------------------------------------------------------------------
  // copyWith
  // -----------------------------------------------------------------------

  RaceBoxData copyWith({
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? speedKmh,
    double? headingDegrees,
    double? altitudeMeters,
    double? gForceX,
    double? gForceY,
    double? gForceZ,
    int? satellites,
    double? hdop,
  }) {
    return RaceBoxData(
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      gForceX: gForceX ?? this.gForceX,
      gForceY: gForceY ?? this.gForceY,
      gForceZ: gForceZ ?? this.gForceZ,
      satellites: satellites ?? this.satellites,
      hdop: hdop ?? this.hdop,
    );
  }

  // -----------------------------------------------------------------------
  // Serialization
  // -----------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'latitude': latitude,
        'longitude': longitude,
        'speedKmh': speedKmh,
        'headingDegrees': headingDegrees,
        'altitudeMeters': altitudeMeters,
        'gForceX': gForceX,
        'gForceY': gForceY,
        'gForceZ': gForceZ,
        'satellites': satellites,
        'hdop': hdop,
      };

  factory RaceBoxData.fromJson(Map<String, dynamic> json) => RaceBoxData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (json['timestamp'] as num).toInt(),
        ),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        speedKmh: (json['speedKmh'] as num).toDouble(),
        headingDegrees: (json['headingDegrees'] as num).toDouble(),
        altitudeMeters: (json['altitudeMeters'] as num).toDouble(),
        gForceX: (json['gForceX'] as num).toDouble(),
        gForceY: (json['gForceY'] as num).toDouble(),
        gForceZ: (json['gForceZ'] as num).toDouble(),
        satellites: (json['satellites'] as num).toInt(),
        hdop: (json['hdop'] as num).toDouble(),
      );

  @override
  String toString() =>
      'RaceBoxData(lat: $latitude, lon: $longitude, speed: ${speedKmh.toStringAsFixed(1)} km/h, '
      'heading: ${headingDegrees.toStringAsFixed(1)}°, sats: $satellites, '
      'gX: ${gForceX.toStringAsFixed(2)} gY: ${gForceY.toStringAsFixed(2)})';
}
