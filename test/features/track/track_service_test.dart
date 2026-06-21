import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/generated/racecoach/v1/track.pb.dart';
import 'package:race_coach/features/track/data/track_service.dart';
import 'package:race_coach/features/track/data/track_library.dart';

void main() {
  // ===========================================================================
  // loadLibrary
  // ===========================================================================

  group('TrackService.loadLibrary', () {
    test('populates availableTracks from the local library', () {
      final service = TrackService();
      expect(service.state.availableTracks, isEmpty);

      service.loadLibrary();

      expect(service.state.availableTracks, isNotEmpty);
      // Should contain at least Thunderhill
      expect(
        service.state.availableTracks.any((t) => t.trackId == 'thunderhill'),
        isTrue,
      );
    });

    test('initial state has no selection', () {
      final service = TrackService();
      service.loadLibrary();

      expect(service.state.selectedTrack, isNull);
      expect(service.state.selectedConfig, isNull);
      expect(service.state.hasSelection, isFalse);
      expect(service.state.autoDetected, isFalse);
    });
  });

  // ===========================================================================
  // selectTrack
  // ===========================================================================

  group('TrackService.selectTrack', () {
    test('sets selectedTrack and selectedConfig', () {
      final service = TrackService();
      service.loadLibrary();

      final track = service.state.availableTracks.first;
      final config = track.configurations.first;

      service.selectTrack(track, config);

      expect(service.state.selectedTrack, isNotNull);
      expect(service.state.selectedTrack!.trackId, equals('thunderhill'));
      expect(service.state.selectedConfig, isNotNull);
      expect(service.state.hasSelection, isTrue);
    });

    test('sets autoDetected to false for manual selection', () {
      final service = TrackService();
      service.loadLibrary();

      final track = service.state.availableTracks.first;
      final config = track.configurations.first;

      service.selectTrack(track, config);
      expect(service.state.autoDetected, isFalse);
    });

    test('preserves availableTracks when selecting', () {
      final service = TrackService();
      service.loadLibrary();
      final trackCount = service.state.availableTracks.length;

      final track = service.state.availableTracks.first;
      service.selectTrack(track, track.configurations.first);

      expect(service.state.availableTracks.length, equals(trackCount));
    });
  });

  // ===========================================================================
  // clearSelection
  // ===========================================================================

  group('TrackService.clearSelection', () {
    test('clears the current selection but preserves library', () {
      final service = TrackService();
      service.loadLibrary();

      final track = service.state.availableTracks.first;
      service.selectTrack(track, track.configurations.first);
      expect(service.state.hasSelection, isTrue);

      service.clearSelection();

      expect(service.state.selectedTrack, isNull);
      expect(service.state.selectedConfig, isNull);
      expect(service.state.hasSelection, isFalse);
      // Library should still be there
      expect(service.state.availableTracks, isNotEmpty);
    });
  });

  // ===========================================================================
  // tryAutoDetect (also tests _haversineDistance indirectly)
  // ===========================================================================

  group('TrackService.tryAutoDetect', () {
    test('detects Thunderhill when position is at its center', () {
      final service = TrackService();
      service.loadLibrary();

      // Thunderhill center is approximately (39.53753, -122.32508)
      final detected = service.tryAutoDetect(39.53753, -122.32508);

      expect(detected, isTrue);
      expect(service.state.selectedTrack, isNotNull);
      expect(service.state.selectedTrack!.trackId, equals('thunderhill'));
      expect(service.state.selectedConfig, isNotNull);
      expect(service.state.autoDetected, isTrue);
    });

    test('detects Thunderhill when position is within 2000m radius', () {
      final service = TrackService();
      service.loadLibrary();

      // A point ~500m from Thunderhill center — still within the 2000m radius
      final detected = service.tryAutoDetect(39.540, -122.325);

      expect(detected, isTrue);
      expect(service.state.selectedTrack!.trackId, equals('thunderhill'));
    });

    test('returns false for a position far from any track', () {
      final service = TrackService();
      service.loadLibrary();

      // San Francisco — ~200 km away from Thunderhill
      final detected = service.tryAutoDetect(37.7749, -122.4194);

      expect(detected, isFalse);
      expect(service.state.selectedTrack, isNull);
      expect(service.state.selectedConfig, isNull);
    });

    test('returns false for the opposite hemisphere', () {
      final service = TrackService();
      service.loadLibrary();

      // Tokyo, Japan
      final detected = service.tryAutoDetect(35.6762, 139.6503);

      expect(detected, isFalse);
    });

    test('returns false for coordinates at (0, 0) — middle of Atlantic', () {
      final service = TrackService();
      service.loadLibrary();

      final detected = service.tryAutoDetect(0.0, 0.0);
      expect(detected, isFalse);
    });

    test('picks the first configuration as default when auto-detected', () {
      final service = TrackService();
      service.loadLibrary();

      service.tryAutoDetect(39.53753, -122.32508);

      // The first config in thunderhillRacewayPark is "East with Bypass"
      expect(service.state.selectedConfig, isNotNull);
      expect(
        service.state.selectedConfig!.configId,
        equals('east-bypass'),
      );
    });
  });

  // ===========================================================================
  // setFinishLine
  // ===========================================================================

  group('TrackService.setFinishLine', () {
    test('updates finishLine on the selected configuration', () {
      final service = TrackService();
      service.loadLibrary();

      final track = service.state.availableTracks.first;
      service.selectTrack(track, track.configurations.first);

      final pointA = GpsData()
        ..latitude = 39.539
        ..longitude = -122.328;
      final pointB = GpsData()
        ..latitude = 39.538
        ..longitude = -122.327;

      service.setFinishLine(pointA, pointB);

      expect(service.state.selectedConfig!.finishLineA.latitude,
          closeTo(39.539, 0.001));
      expect(service.state.selectedConfig!.finishLineB.latitude,
          closeTo(39.538, 0.001));
    });

    test('does nothing when no config is selected', () {
      final service = TrackService();
      service.loadLibrary();
      // No selection — setFinishLine should be a no-op.

      final pointA = GpsData()..latitude = 39.539;
      final pointB = GpsData()..latitude = 39.538;
      service.setFinishLine(pointA, pointB);

      expect(service.state.selectedConfig, isNull);
    });
  });

  // ===========================================================================
  // TrackState
  // ===========================================================================

  group('TrackState', () {
    test('initial state has empty tracks and no selection', () {
      final state = TrackState.initial();
      expect(state.availableTracks, isEmpty);
      expect(state.selectedTrack, isNull);
      expect(state.selectedConfig, isNull);
      expect(state.hasSelection, isFalse);
      expect(state.autoDetected, isFalse);
    });

    test('hasSelection is true only when both track and config are set', () {
      final track = Track()..trackId = 'test';
      final config = TrackConfiguration()..configId = 'test-config';

      // Only track set
      final state1 = TrackState(
        availableTracks: [],
        selectedTrack: track,
      );
      expect(state1.hasSelection, isFalse);

      // Only config set
      final state2 = TrackState(
        availableTracks: [],
        selectedConfig: config,
      );
      expect(state2.hasSelection, isFalse);

      // Both set
      final state3 = TrackState(
        availableTracks: [],
        selectedTrack: track,
        selectedConfig: config,
      );
      expect(state3.hasSelection, isTrue);
    });

    test('copyWith preserves fields when none specified', () {
      final track = Track()..trackId = 'test';
      final config = TrackConfiguration()..configId = 'cfg';
      final original = TrackState(
        availableTracks: [track],
        selectedTrack: track,
        selectedConfig: config,
        autoDetected: true,
      );

      final copy = original.copyWith();
      expect(copy.availableTracks.length, equals(1));
      expect(copy.selectedTrack!.trackId, equals('test'));
      expect(copy.selectedConfig!.configId, equals('cfg'));
      expect(copy.autoDetected, isTrue);
    });
  });

  // ===========================================================================
  // Track library sanity check
  // ===========================================================================

  group('Track library', () {
    test('getLocalTrackLibrary returns at least one track', () {
      final tracks = getLocalTrackLibrary();
      expect(tracks, isNotEmpty);
    });

    test('Thunderhill has a center and autoDetectRadius', () {
      final tracks = getLocalTrackLibrary();
      final thunderhill = tracks.firstWhere((t) => t.trackId == 'thunderhill');

      expect(thunderhill.hasCenter(), isTrue);
      expect(thunderhill.center.latitude, closeTo(39.53753, 0.01));
      expect(thunderhill.center.longitude, closeTo(-122.32508, 0.01));
      expect(thunderhill.autoDetectRadiusMeters, equals(2000.0));
    });

    test('Thunderhill has at least one configuration', () {
      final tracks = getLocalTrackLibrary();
      final thunderhill = tracks.firstWhere((t) => t.trackId == 'thunderhill');

      expect(thunderhill.configurations, isNotEmpty);
      expect(thunderhill.configurations.length, greaterThanOrEqualTo(4));
    });
  });
}
