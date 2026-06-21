import 'dart:developer' as developer;

/// Lightweight logging utility wrapping [dart:developer].
///
/// Usage:
/// ```dart
/// Log.info('Connected to device', tag: 'BLE');
/// Log.error('Parse failed', tag: 'Telemetry', error: e, stackTrace: st);
/// ```
class Log {
  Log._();

  static const String _defaultTag = 'RaceCoach';

  /// Verbose / debug-level message.
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 500, error: error, stackTrace: stackTrace);
  }

  /// Informational message – normal operation events.
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 800, error: error, stackTrace: stackTrace);
  }

  /// Warning – something unexpected but recoverable happened.
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 900, error: error, stackTrace: stackTrace);
  }

  /// Error – something failed.
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 1000, error: error, stackTrace: stackTrace);
  }

  static void _log(
    String message, {
    String? tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
