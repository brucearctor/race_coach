import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/generated/racecoach/v1/track.pb.dart';

// =============================================================================
// Hardcoded track library — will move to Firestore later.
// =============================================================================

/// Returns all tracks available in the local library.
List<Track> getLocalTrackLibrary() => [
      thunderhillRacewayPark(),
    ];

// ---------------------------------------------------------------------------
// Thunderhill Raceway Park — Willows, CA
// ---------------------------------------------------------------------------

Track thunderhillRacewayPark() {
  return Track()
    ..trackId = 'thunderhill'
    ..name = 'Thunderhill Raceway Park'
    ..country = 'US'
    ..region = 'CA'
    ..center = _gps(39.53753, -122.32508)
    ..autoDetectRadiusMeters = 2000.0
    ..configurations.addAll([
      _thunderhillEastBypass(),
      _thunderhillEastFull(),
      _thunderhillWest(),
      _thunderhillFull5Mile(),
    ]);
}

/// Thunderhill East with bypass — ~2 miles.
/// Bypass skips Turn 5 (Crow's Nest), connecting T4 exit directly to T6.
TrackConfiguration _thunderhillEastBypass() {
  return TrackConfiguration()
    ..configId = 'east-bypass'
    ..name = 'East with Bypass'
    ..lengthMeters = 3219 // ~2.0 miles
    ..direction = Direction.DIRECTION_COUNTER_CLOCKWISE
    // Start/finish line on the front straight.
    // NOTE: Fine-tune these at the track — set from the pit wall to
    // the opposite edge of the track surface.
    ..finishLineA = _gps(39.53898, -122.32768)
    ..finishLineB = _gps(39.53880, -122.32780)
    ..sectors.addAll([
      SectorSplit()
        ..sectorNumber = 1
        ..name = 'S1 (T1–T3)'
        ..pointA = _gps(39.53650, -122.32920)
        ..pointB = _gps(39.53635, -122.32935),
      SectorSplit()
        ..sectorNumber = 2
        ..name = 'S2 (T4–Bypass–T8)'
        ..pointA = _gps(39.53520, -122.32340)
        ..pointB = _gps(39.53505, -122.32355),
    ])
    ..corners.addAll([
      _corner(1, 'Turn 1', 39.53810, -122.32920, 39.53840, -122.32880,
          39.53790, -122.32950),
      _corner(2, 'Turn 2', 39.53720, -122.33050, 39.53750, -122.33010,
          39.53700, -122.33070),
      _corner(3, 'Turn 3', 39.53650, -122.32990, 39.53680, -122.33030,
          39.53630, -122.32950),
      _corner(4, 'Turn 4', 39.53570, -122.32850, 39.53600, -122.32900,
          39.53550, -122.32800),
      // Bypass — no Turn 5
      _corner(6, 'Turn 6', 39.53480, -122.32450, 39.53500, -122.32500,
          39.53460, -122.32400),
      _corner(7, 'Turn 7', 39.53520, -122.32280, 39.53500, -122.32330,
          39.53540, -122.32240),
      _corner(8, 'Cyclone (T8)', 39.53610, -122.32200, 39.53580, -122.32250,
          39.53640, -122.32180),
      _corner(9, 'Turn 9', 39.53730, -122.32300, 39.53700, -122.32250,
          39.53760, -122.32350),
      _corner(
          10, 'Turn 10', 39.53830, -122.32480, 39.53800, -122.32430,
          39.53860, -122.32540),
    ]);
}

/// Thunderhill East full — ~3 miles (no bypass).
TrackConfiguration _thunderhillEastFull() {
  return TrackConfiguration()
    ..configId = 'east-full'
    ..name = 'East Full Course'
    ..lengthMeters = 4610 // ~2.86 miles
    ..direction = Direction.DIRECTION_COUNTER_CLOCKWISE
    ..finishLineA = _gps(39.53898, -122.32768)
    ..finishLineB = _gps(39.53880, -122.32780);
  // Corners and sectors to be populated.
}

/// Thunderhill West — ~2 miles.
TrackConfiguration _thunderhillWest() {
  return TrackConfiguration()
    ..configId = 'west'
    ..name = 'West Course'
    ..lengthMeters = 3219 // ~2.0 miles
    ..direction = Direction.DIRECTION_COUNTER_CLOCKWISE;
  // To be populated.
}

/// Thunderhill Full 5-mile — East + West combined.
TrackConfiguration _thunderhillFull5Mile() {
  return TrackConfiguration()
    ..configId = 'full-5-mile'
    ..name = 'Full 5-Mile Course'
    ..lengthMeters = 8047 // ~5.0 miles
    ..direction = Direction.DIRECTION_COUNTER_CLOCKWISE;
  // To be populated.
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GpsData _gps(double lat, double lon) {
  return GpsData()
    ..latitude = lat
    ..longitude = lon;
}

Corner _corner(int number, String name, double apexLat, double apexLon,
    double entryLat, double entryLon, double exitLat, double exitLon) {
  return Corner()
    ..number = number
    ..name = name
    ..apex = _gps(apexLat, apexLon)
    ..entry = _gps(entryLat, entryLon)
    ..exit = _gps(exitLat, exitLon);
}
