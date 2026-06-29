import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/coaching/data/turn_announcer.dart';

void main() {
  group('shortNameForTesting', () {
    test('extracts name before parentheses', () {
      expect(shortNameForTesting('Cyclone (T8)'), 'Cyclone');
    });

    test('trims whitespace around extracted name', () {
      expect(shortNameForTesting('Cyclone  (T8)'), 'Cyclone');
    });

    test('returns full name when no parentheses', () {
      expect(shortNameForTesting('Turn 1'), 'Turn 1');
    });

    test('returns full name for empty parens at start', () {
      // Edge: parens at index 0 — parenIndex is NOT > 0.
      expect(shortNameForTesting('(T8) Cyclone'), '(T8) Cyclone');
    });

    test('handles empty string', () {
      expect(shortNameForTesting(''), '');
    });
  });

  group('distanceMetersForTesting', () {
    test('same point returns zero', () {
      final d = distanceMetersForTesting(37.0, -122.0, 37.0, -122.0);
      expect(d, closeTo(0.0, 0.01));
    });

    test('known distance — equator 1 degree longitude ≈ 111 km', () {
      final d = distanceMetersForTesting(0.0, 0.0, 0.0, 1.0);
      expect(d, closeTo(111195, 200)); // ~111 km ± 200m
    });

    test('known distance — 1 degree latitude ≈ 111 km', () {
      final d = distanceMetersForTesting(0.0, 0.0, 1.0, 0.0);
      expect(d, closeTo(111195, 200));
    });

    test('short distance — Thunderhill T1 entry to apex', () {
      // T1 entry: 39.5381, -122.3322 (approx)
      // T1 apex:  39.5385, -122.3318 (approx)
      // Should be roughly 50-100 meters.
      final d = distanceMetersForTesting(
        39.5381,
        -122.3322,
        39.5385,
        -122.3318,
      );
      expect(d, greaterThan(30));
      expect(d, lessThan(200));
    });

    test('within 100m returns true for announce threshold', () {
      // Two points ~50m apart at mid latitudes.
      final d = distanceMetersForTesting(
        39.5380,
        -122.3320,
        39.5384,
        -122.3320,
      );
      expect(d, lessThan(100)); // Within announce range
      expect(d, greaterThan(10)); // But not on top of each other
    });

    test('far apart points exceed threshold', () {
      // SF to Thunderhill ~200km.
      final d = distanceMetersForTesting(
        37.7749,
        -122.4194, // SF
        39.5380,
        -122.3320, // Thunderhill
      );
      expect(d, greaterThan(100000)); // > 100km
    });

    test('negative coordinates work (southern hemisphere)', () {
      final d = distanceMetersForTesting(
        -33.8688,
        151.2093,
        -33.8688,
        151.2093,
      );
      expect(d, closeTo(0.0, 0.01));
    });
  });
}
