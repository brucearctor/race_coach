import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'package:race_coach/generated/racecoach/v1/session.pb.dart';
import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';
import 'package:race_coach/features/session/domain/raw_frame_list.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';
import 'package:race_coach/features/telemetry/domain/telemetry_state.dart';
import 'package:race_coach/features/track/data/track_service.dart';
import 'package:race_coach/features/racebox/data/racebox_providers.dart';

// =============================================================================
// SessionRecorderState — immutable state for the recorder
// =============================================================================

/// Describes the current state of the session recorder.
class SessionRecorderState {
  const SessionRecorderState({
    this.isRecording = false,
    this.sessionId,
    this.startTime,
    this.frameCount = 0,
    this.lapCount = 0,
  });

  final bool isRecording;
  final String? sessionId;
  final DateTime? startTime;
  final int frameCount;
  final int lapCount;

  /// A fresh idle state.
  factory SessionRecorderState.idle() => const SessionRecorderState();

  SessionRecorderState copyWith({
    bool? isRecording,
    String? sessionId,
    DateTime? startTime,
    int? frameCount,
    int? lapCount,
  }) {
    return SessionRecorderState(
      isRecording: isRecording ?? this.isRecording,
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      frameCount: frameCount ?? this.frameCount,
      lapCount: lapCount ?? this.lapCount,
    );
  }

  @override
  String toString() =>
      'SessionRecorderState(recording: $isRecording, id: $sessionId, '
      'frames: $frameCount, laps: $lapCount)';
}

// =============================================================================
// SessionRecorder — StateNotifier
// =============================================================================

/// Records incoming [TelemetryFrame]s into a [Session] protobuf and writes
/// the result to disk as binary protobuf files.
///
/// Lifecycle:
///   1. [startRecording] — creates session directory, begins buffering.
///   2. [addFrame]       — called for every telemetry frame while recording.
///   3. [markLap]        — finalises the current lap and starts a new one.
///   4. [stopRecording]  — writes session.pb + raw_frames.pb to disk.
class SessionRecorder extends StateNotifier<SessionRecorderState> {
  SessionRecorder({required this.trackName, required this.configName})
    : super(SessionRecorderState.idle());

  /// Human-readable track + configuration name used for directory naming and
  /// the Session proto's `track_name` field.
  final String trackName;
  final String configName;

  // ---------------------------------------------------------------------------
  // Internal buffers
  // ---------------------------------------------------------------------------

  /// All frames captured during this session (for raw_frames.pb).
  final List<TelemetryFrame> _allFrames = [];

  /// Frames buffered for the *current* (in-progress) lap.
  final List<TelemetryFrame> _currentLapFrames = [];

  /// Completed laps accumulated during this session.
  final List<Lap> _completedLaps = [];

  /// Timestamp when the current lap started (for lap-level start_time).
  DateTime? _currentLapStartTime;

  // ---------------------------------------------------------------------------
  // Recording lifecycle
  // ---------------------------------------------------------------------------

  /// Begin a new recording session.
  ///
  /// Creates the session directory tree under the app documents folder and
  /// initialises internal buffers.
  Future<void> startRecording() async {
    if (state.isRecording) return; // Already recording.

    final now = DateTime.now();
    final sessionId = _buildSessionId(now);

    _allFrames.clear();
    _currentLapFrames.clear();
    _completedLaps.clear();
    _currentLapStartTime = now;

    // Ensure the session directory exists.
    final dir = await _sessionDirectory(sessionId);
    await dir.create(recursive: true);

    state = SessionRecorderState(
      isRecording: true,
      sessionId: sessionId,
      startTime: now,
      frameCount: 0,
      lapCount: 0,
    );
  }

  /// Stop recording and persist the session to disk.
  ///
  /// Any frames still in the current-lap buffer are flushed into a final
  /// "incomplete" lap so no data is lost.
  Future<void> stopRecording() async {
    if (!state.isRecording) return;

    final now = DateTime.now();

    // Flush any remaining frames as a partial lap.
    if (_currentLapFrames.isNotEmpty) {
      _completedLaps.add(
        _buildLap(
          lapNumber: _completedLaps.length + 1,
          lapTimeSeconds: 0, // Unknown — lap was not completed.
          frames: _currentLapFrames,
        ),
      );
      _currentLapFrames.clear();
    }

    // Assemble the Session proto.
    final session = Session(
      sessionId: state.sessionId,
      trackName: _fullTrackName,
      startTime: _timestampFromDateTime(state.startTime!),
      endTime: _timestampFromDateTime(now),
      laps: _completedLaps,
    );

    // Write files.
    await _writeSessionFiles(session);

    // Reset state.
    _allFrames.clear();
    _completedLaps.clear();
    state = SessionRecorderState.idle();
  }

  /// Buffer a single telemetry frame.
  ///
  /// Call this from the provider that watches [telemetryBusProvider] whenever
  /// a new frame arrives and recording is active.
  void addFrame(TelemetryFrame frame) {
    if (!state.isRecording) return;

    _allFrames.add(frame);
    _currentLapFrames.add(frame);

    state = state.copyWith(frameCount: state.frameCount + 1);
  }

  /// Mark the end of the current lap and begin a new one.
  ///
  /// [lapTime] is the elapsed duration for the completed lap (as measured by
  /// the lap timer / finish-line crossing logic).
  void markLap(Duration lapTime) {
    if (!state.isRecording) return;

    final lap = _buildLap(
      lapNumber: _completedLaps.length + 1,
      lapTimeSeconds: lapTime.inMilliseconds / 1000.0,
      frames: _currentLapFrames,
    );

    _completedLaps.add(lap);
    _currentLapFrames.clear();
    _currentLapStartTime = DateTime.now();

    state = state.copyWith(lapCount: state.lapCount + 1);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Build a filesystem-safe session id from the date and track name.
  ///
  /// Example: `2026-06-22_thunderhill_east-bypass`
  String _buildSessionId(DateTime now) {
    final date = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    final safeName = _fullTrackName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    return '${date}_$safeName';
  }

  /// Combined track + config label (e.g. "Thunderhill East Bypass").
  String get _fullTrackName {
    if (configName.isNotEmpty) return '$trackName $configName';
    return trackName;
  }

  /// Pad a number to two digits.
  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// Build a [Lap] proto from buffered frames.
  Lap _buildLap({
    required int lapNumber,
    required double lapTimeSeconds,
    required List<TelemetryFrame> frames,
  }) {
    return Lap(
      lapNumber: lapNumber,
      lapTimeSeconds: lapTimeSeconds,
      telemetry: frames,
      startTime: _currentLapStartTime != null
          ? _timestampFromDateTime(_currentLapStartTime!)
          : null,
    );
  }

  /// Convert a Dart [DateTime] to a protobuf [Timestamp].
  static Timestamp _timestampFromDateTime(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    return Timestamp(seconds: Int64(ms ~/ 1000), nanos: (ms % 1000) * 1000000);
  }

  /// Get (or create) the session directory for a given [sessionId].
  Future<Directory> _sessionDirectory(String sessionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/sessions/$sessionId');
  }

  /// Write `session.pb` and `raw_frames.pb` into the session directory.
  Future<void> _writeSessionFiles(Session session) async {
    final dir = await _sessionDirectory(state.sessionId!);
    await dir.create(recursive: true);

    // session.pb — the full structured session.
    final sessionFile = File('${dir.path}/session.pb');
    await sessionFile.writeAsBytes(session.writeToBuffer());

    // raw_frames.pb — flat length-delimited stream of every frame.
    final rawFile = File('${dir.path}/raw_frames.pb');
    final rawBytes = encodeRawFrames(_allFrames);
    await rawFile.writeAsBytes(rawBytes);
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

/// The session recorder notifier.
///
/// Reads the currently-selected track/config to label the session directory.
final sessionRecorderProvider =
    StateNotifierProvider<SessionRecorder, SessionRecorderState>((ref) {
      final trackState = ref.read(trackServiceProvider);
      final trackName = trackState.selectedTrack?.name ?? 'unknown-track';
      final configName = trackState.selectedConfig?.name ?? '';

      return SessionRecorder(trackName: trackName, configName: configName);
    });

/// Bridges the [isRecordingProvider] toggle and the [telemetryBusProvider]
/// stream into the [SessionRecorder].
///
/// Watch this provider from your top-level widget (or a dedicated
/// controller widget) to keep the recorder in sync.
final sessionRecordingBridgeProvider = Provider<void>((ref) {
  final isRecording = ref.watch(isRecordingProvider);
  final recorder = ref.read(sessionRecorderProvider.notifier);
  final recorderState = ref.watch(sessionRecorderProvider);

  // Start / stop based on the toggle.
  if (isRecording && !recorderState.isRecording) {
    recorder.startRecording().catchError((e) {
      debugPrint('[SessionBridge] Error starting recording: $e');
    });
  } else if (!isRecording && recorderState.isRecording) {
    recorder.stopRecording().catchError((e) {
      debugPrint('[SessionBridge] Error stopping recording: $e');
    });
  }

  // Feed telemetry frames while recording.
  if (isRecording) {
    ref.listen<TelemetryState>(telemetryBusProvider, (previous, next) {
      // Build a TelemetryFrame snapshot from the current bus state.
      if (next.hasGps || next.hasMotion || next.hasEngine || next.hasFuel) {
        final frame = TelemetryFrame()
          ..arrivalTimestamp = SessionRecorder._timestampFromDateTime(
            DateTime.now(),
          );
        if (next.gps != null) frame.gps = next.gps!;
        if (next.motion != null) frame.motion = next.motion!;
        if (next.engine != null) frame.engine = next.engine!;
        if (next.fuel != null) frame.fuel = next.fuel!;
        recorder.addFrame(frame);
      }
    });
  }
});
