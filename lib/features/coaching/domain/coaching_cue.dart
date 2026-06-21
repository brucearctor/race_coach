/// The type of coaching cue being delivered.
enum CoachingCueType {
  braking,
  throttle,
  line,
  speed,
  sectorTime,
  general,
}

/// Priority level for a coaching cue.
///
/// Higher priority cues can interrupt lower-priority speech
/// and are delivered sooner in the queue.
enum CuePriority {
  low,
  medium,
  high,
  critical,
}

/// A single coaching instruction to be delivered to the driver.
///
/// Immutable value object combining the cue content with its
/// categorisation and timing metadata.
class CoachingCue {
  const CoachingCue({
    required this.type,
    required this.message,
    required this.priority,
    required this.timestamp,
  });

  /// What aspect of driving this cue relates to.
  final CoachingCueType type;

  /// The human-readable coaching instruction (spoken via TTS).
  final String message;

  /// How urgently this cue should be delivered.
  final CuePriority priority;

  /// When this cue was created.
  final DateTime timestamp;

  CoachingCue copyWith({
    CoachingCueType? type,
    String? message,
    CuePriority? priority,
    DateTime? timestamp,
  }) {
    return CoachingCue(
      type: type ?? this.type,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'CoachingCue($type, priority: $priority, message: "$message")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachingCue &&
          type == other.type &&
          message == other.message &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(type, message, timestamp);
}
