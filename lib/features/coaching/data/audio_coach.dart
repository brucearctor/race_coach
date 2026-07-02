import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:race_coach/features/coaching/domain/coaching_cue.dart';
import 'package:race_coach/features/coaching/domain/cue_config.dart';

/// Text-to-speech wrapper that manages a priority queue of coaching cues,
/// prevents overlapping speech, and enforces a minimum interval between cues.
class AudioCoach {
  AudioCoach() {
    _tts = FlutterTts();
    _initFuture = _init();
  }

  late final FlutterTts _tts;

  /// Completes when TTS is fully configured.
  late final Future<void> _initFuture;

  /// Whether audio coaching is enabled.
  bool _enabled = true;

  /// Whether TTS is currently speaking.
  bool _isSpeaking = false;

  /// Queue of pending cues, ordered by priority then timestamp.
  final Queue<CoachingCue> _queue = Queue<CoachingCue>();

  /// When the last cue finished playing.
  DateTime _lastCueEnd = DateTime.fromMillisecondsSinceEpoch(0);

  /// Minimum interval between cues (prevents information overload).
  Duration minInterval = const Duration(seconds: 3);

  // ── Configuration ──────────────────────────────────────────────────

  double _volume = 1.0;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  Map<String, String>? _currentVoice;

  double get volume => _volume;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  bool get isEnabled => _enabled;

  /// The currently selected voice, or null for system default.
  Map<String, String>? get currentVoice => _currentVoice;

  /// Fetch available English voices from the TTS engine.
  Future<List<Map<String, String>>> getAvailableVoices() async {
    await _initFuture;
    final voices = await _tts.getVoices;
    if (voices == null) return [];

    final list = <Map<String, String>>[];
    for (final v in voices) {
      final map = Map<String, String>.from(v as Map);
      final locale = map['locale'] ?? '';
      // Filter to English voices only.
      if (locale.startsWith('en')) {
        list.add(map);
      }
    }
    // Sort by locale then name for consistent ordering.
    list.sort((a, b) {
      final localeCompare = (a['locale'] ?? '').compareTo(b['locale'] ?? '');
      if (localeCompare != 0) return localeCompare;
      return (a['name'] ?? '').compareTo(b['name'] ?? '');
    });
    return list;
  }

  /// Set the TTS voice. Pass null to reset to system default.
  Future<void> setVoice(Map<String, String>? voice) async {
    await _initFuture;
    _currentVoice = voice;
    if (voice != null) {
      await _tts.setVoice(voice);
    } else {
      await _tts.setLanguage('en-US');
    }
  }

  Future<void> _init() async {
    await _tts.setLanguage('en-US');
    await _tts.setVolume(_volume);
    await _tts.setSpeechRate(_speechRate);
    await _tts.setPitch(_pitch);

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _lastCueEnd = DateTime.now();
      _processQueue();
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      _lastCueEnd = DateTime.now();
    });
  }

  /// Enable or disable audio coaching.
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      _tts.stop();
      _queue.clear();
      _isSpeaking = false;
    }
  }

  /// Set the TTS volume (0.0 – 1.0).
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
  }

  /// Set the TTS speech rate (0.0 – 1.0).
  Future<void> setSpeechRate(double value) async {
    _speechRate = value.clamp(0.0, 1.0);
    await _tts.setSpeechRate(_speechRate);
  }

  /// Set the TTS pitch (0.5 – 2.0).
  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
  }

  /// Apply coaching cue configuration (Dart-side audio settings).
  Future<void> applyConfig(DartCueConfig config) async {
    await _initFuture;
    minInterval = Duration(seconds: config.minCueIntervalS);
    await setVolume(config.volume);
    await setSpeechRate(config.speechRate);
    _processQueue(); // Re-evaluate pending cues with new settings
  }

  // ── Public API ─────────────────────────────────────────────────────

  /// Add a coaching cue to the queue. It will be spoken when appropriate.
  Future<void> speak(CoachingCue cue) async {
    if (!_enabled) return;
    await _initFuture;

    // Critical cues bypass the queue.
    if (cue.priority == CuePriority.critical) {
      await speakImmediate(cue.message);
      return;
    }

    _queue.addLast(cue);
    _processQueue();
  }

  /// Interrupt any current speech and speak this message immediately.
  Future<void> speakImmediate(String message) async {
    if (!_enabled) return;
    await _initFuture;

    await _tts.stop();
    _isSpeaking = true;
    await _tts.speak(message);
  }

  /// Speak a test message to verify audio is working.
  Future<void> speakTest() async {
    final saved = _enabled;
    _enabled = true;
    await speakImmediate('Audio coaching is working.');
    _enabled = saved;
  }

  /// Dispose of TTS resources.
  Future<void> dispose() async {
    await _tts.stop();
  }

  // ── Internal ───────────────────────────────────────────────────────

  void _processQueue() {
    if (_isSpeaking || _queue.isEmpty || !_enabled) return;

    // Enforce minimum interval.
    final sinceLastCue = DateTime.now().difference(_lastCueEnd);
    if (sinceLastCue < minInterval) {
      // Schedule a retry after the remaining interval.
      final remaining = minInterval - sinceLastCue;
      Future.delayed(remaining, _processQueue);
      return;
    }

    final cue = _queue.removeFirst();
    _isSpeaking = true;
    _tts.speak(cue.message);
  }
}

// ── Riverpod provider ──────────────────────────────────────────────────

final audioCoachProvider = Provider<AudioCoach>((ref) {
  final coach = AudioCoach();
  ref.onDispose(() => coach.dispose());
  return coach;
});
