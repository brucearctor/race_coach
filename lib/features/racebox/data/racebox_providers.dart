import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/racebox/domain/racebox_data.dart';

/// Primary state holder for current RaceBox data.
///
/// NOTE: This is also available as a stream via [raceBoxDataStreamProvider]
/// in racebox_service.dart. Widgets that need reactive updates should prefer
/// the stream provider. This StateProvider is used by the adapter bridge
/// for imperative updates. TODO: Consolidate to single source of truth.
final raceBoxDataProvider = StateProvider<RaceBoxData>(
  (ref) => RaceBoxData.empty(),
);

/// Connection status of the RaceBox device.
enum RaceBoxConnectionStatus { disconnected, scanning, connecting, connected }

/// Provides the current BLE connection status.
final raceBoxConnectionStatusProvider = StateProvider<RaceBoxConnectionStatus>(
  (ref) => RaceBoxConnectionStatus.disconnected,
);

/// Whether we are currently recording a session.
final isRecordingProvider = StateProvider<bool>((ref) => false);
