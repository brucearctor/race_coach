import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/features/racebox/domain/racebox_data.dart';

/// Provides the latest [RaceBoxData] telemetry sample.
///
/// For now this is a simple [StateProvider] that starts with an empty sample.
/// The BLE service will update this as data arrives.
final raceBoxDataProvider = StateProvider<RaceBoxData>(
  (ref) => RaceBoxData.empty(),
);

/// Connection status of the RaceBox device.
enum RaceBoxConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
}

/// Provides the current BLE connection status.
final raceBoxConnectionStatusProvider = StateProvider<RaceBoxConnectionStatus>(
  (ref) => RaceBoxConnectionStatus.disconnected,
);

/// Whether we are currently recording a session.
final isRecordingProvider = StateProvider<bool>((ref) => false);
