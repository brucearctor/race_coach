import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:race_coach/generated/racecoach/v1/telemetry.pbenum.dart';
import 'package:race_coach/features/racebox/data/racebox_providers.dart';
import 'package:race_coach/features/telemetry/data/adapters/phone_gps_adapter.dart';
import 'package:race_coach/features/telemetry/data/adapters/racebox_adapter.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';

// =============================================================================
// Source priority
// =============================================================================

/// GPS / motion source priority — lower index = higher priority.
///
/// When multiple sources can provide the same data category the adapter
/// manager will suppress the lower-priority source's writes to the bus.
const List<SourceType> _gpsPriority = [
  SourceType.SOURCE_TYPE_RACEBOX_MINI,
  SourceType.SOURCE_TYPE_VBOX,
  SourceType.SOURCE_TYPE_AIM,
  SourceType.SOURCE_TYPE_PHONE_GPS,
];

const List<SourceType> _motionPriority = [
  SourceType.SOURCE_TYPE_RACEBOX_MINI,
  SourceType.SOURCE_TYPE_VBOX,
  SourceType.SOURCE_TYPE_AIM,
  SourceType.SOURCE_TYPE_PHONE_IMU,
];

/// Engine / fuel data only comes from OBD, so no priority conflict today.
const List<SourceType> _enginePriority = [SourceType.SOURCE_TYPE_OBD_BLE];

// =============================================================================
// AdapterManagerState
// =============================================================================

/// Immutable snapshot of the adapter manager's bookkeeping.
class AdapterManagerState {
  /// Source types whose adapters are currently running.
  final Set<SourceType> activeAdapters;

  /// For each data category, which source is currently authoritative.
  final SourceType? gpsAuthority;
  final SourceType? motionAuthority;
  final SourceType? engineAuthority;

  const AdapterManagerState({
    this.activeAdapters = const {},
    this.gpsAuthority,
    this.motionAuthority,
    this.engineAuthority,
  });

  factory AdapterManagerState.empty() => const AdapterManagerState();

  AdapterManagerState copyWith({
    Set<SourceType>? activeAdapters,
    SourceType? gpsAuthority,
    SourceType? motionAuthority,
    SourceType? engineAuthority,
    bool clearGpsAuthority = false,
    bool clearMotionAuthority = false,
    bool clearEngineAuthority = false,
  }) {
    return AdapterManagerState(
      activeAdapters: activeAdapters ?? this.activeAdapters,
      gpsAuthority: clearGpsAuthority
          ? null
          : (gpsAuthority ?? this.gpsAuthority),
      motionAuthority: clearMotionAuthority
          ? null
          : (motionAuthority ?? this.motionAuthority),
      engineAuthority: clearEngineAuthority
          ? null
          : (engineAuthority ?? this.engineAuthority),
    );
  }

  @override
  String toString() =>
      'AdapterManagerState(active: $activeAdapters, '
      'gps: $gpsAuthority, motion: $motionAuthority, '
      'engine: $engineAuthority)';
}

// =============================================================================
// AdapterManager
// =============================================================================

/// Coordinates active telemetry adapters and enforces source priority.
///
/// Call [activateSource] when a device connects and [deactivateSource] when
/// it disconnects.  The manager will start/stop the corresponding adapter
/// provider and recalculate which source is authoritative for each data
/// category.
class AdapterManager extends StateNotifier<AdapterManagerState> {
  final Ref _ref;

  AdapterManager(this._ref) : super(AdapterManagerState.empty());

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Register a source as connected and start its adapter.
  void activateSource(SourceType source) {
    if (state.activeAdapters.contains(source)) return;

    final updatedAdapters = {...state.activeAdapters, source};
    state = state.copyWith(activeAdapters: updatedAdapters);

    _startAdapter(source);
    _recalculateAuthorities();
  }

  /// Unregister a source (device disconnected) and stop its adapter.
  void deactivateSource(SourceType source) {
    if (!state.activeAdapters.contains(source)) return;

    final updatedAdapters = {...state.activeAdapters}..remove(source);
    state = state.copyWith(activeAdapters: updatedAdapters);

    _stopAdapter(source);
    _ref.read(telemetryBusProvider.notifier).removeSource(source);
    _recalculateAuthorities();
  }

  /// Whether the given [source] should be allowed to write GPS data to the
  /// bus right now based on priority.
  bool isGpsAuthoritative(SourceType source) => state.gpsAuthority == source;

  /// Whether the given [source] should be allowed to write motion data to the
  /// bus right now based on priority.
  bool isMotionAuthoritative(SourceType source) =>
      state.motionAuthority == source;

  /// Whether the given [source] should be allowed to write engine data.
  bool isEngineAuthoritative(SourceType source) =>
      state.engineAuthority == source;

  // ---------------------------------------------------------------------------
  // Adapter lifecycle
  // ---------------------------------------------------------------------------

  void _startAdapter(SourceType source) {
    switch (source) {
      case SourceType.SOURCE_TYPE_RACEBOX_MINI:
        // The RaceBox bridge is a Provider — just reading it activates the
        // watch chain.  We kick it once here so it starts pumping.
        _ref.read(raceBoxTelemetryBridgeProvider);
        break;

      case SourceType.SOURCE_TYPE_PHONE_GPS:
        _ref.read(phoneGpsEnabledProvider.notifier).state = true;
        break;

      // Future sources (OBD, VBOX, etc.) will be added here.
      default:
        break;
    }
  }

  void _stopAdapter(SourceType source) {
    switch (source) {
      case SourceType.SOURCE_TYPE_PHONE_GPS:
        _ref.read(phoneGpsEnabledProvider.notifier).state = false;
        break;

      // RaceBox adapter is inherently reactive — it stops producing frames
      // when the BLE provider stops updating.  No explicit teardown needed.
      default:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Priority resolution
  // ---------------------------------------------------------------------------

  void _recalculateAuthorities() {
    state = state.copyWith(
      gpsAuthority: _bestSource(_gpsPriority),
      motionAuthority: _bestSource(_motionPriority),
      engineAuthority: _bestSource(_enginePriority),
      // Clear authorities if no source qualifies.
      clearGpsAuthority: _bestSource(_gpsPriority) == null,
      clearMotionAuthority: _bestSource(_motionPriority) == null,
      clearEngineAuthority: _bestSource(_enginePriority) == null,
    );
  }

  /// Walk the priority list and return the first source that is currently
  /// active, or `null` if none qualify.
  SourceType? _bestSource(List<SourceType> priorityList) {
    for (final source in priorityList) {
      if (state.activeAdapters.contains(source)) return source;
    }
    return null;
  }
}

// =============================================================================
// Riverpod provider
// =============================================================================

/// The single [AdapterManager] instance.
final adapterManagerProvider =
    StateNotifierProvider<AdapterManager, AdapterManagerState>(
      (ref) => AdapterManager(ref),
    );

/// Convenience provider: automatically activates the RaceBox adapter when
/// the RaceBox device transitions to [RaceBoxConnectionStatus.connected]
/// and deactivates it on disconnect.
///
/// Watch this from a top-level widget (e.g. `App`) to wire up the
/// auto-activation lifecycle.
final raceBoxAutoActivationProvider = Provider<void>((ref) {
  final connectionStatus = ref.watch(raceBoxConnectionStatusProvider);

  if (connectionStatus == RaceBoxConnectionStatus.connected) {
    ref
        .read(adapterManagerProvider.notifier)
        .activateSource(SourceType.SOURCE_TYPE_RACEBOX_MINI);
  } else {
    ref
        .read(adapterManagerProvider.notifier)
        .deactivateSource(SourceType.SOURCE_TYPE_RACEBOX_MINI);
  }
});
