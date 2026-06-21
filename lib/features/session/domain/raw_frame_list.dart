import 'dart:typed_data';

import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';

// =============================================================================
// Raw Frame List — length-delimited proto serialisation
// =============================================================================
//
// Serialises a list of TelemetryFrames as a flat byte stream using the
// standard length-delimited approach:
//
//   [ 4-byte big-endian length | proto bytes ] × N
//
// This is the "raw_frames.pb" format used alongside the structured Session
// proto.  It preserves every frame in arrival order regardless of lap
// boundaries, which is useful for full-session replay and post-hoc analysis.

/// Encode a list of [TelemetryFrame]s into a single [Uint8List] using
/// length-delimited framing (4-byte big-endian prefix per message).
Uint8List encodeRawFrames(List<TelemetryFrame> frames) {
  // Pre-serialise each frame so we can compute total length in one pass.
  final serialised = <Uint8List>[];
  var totalBytes = 0;
  for (final frame in frames) {
    final bytes = frame.writeToBuffer();
    serialised.add(bytes);
    totalBytes += 4 + bytes.length; // 4-byte header + payload
  }

  final buffer = ByteData(totalBytes);
  var offset = 0;
  for (final bytes in serialised) {
    buffer.setUint32(offset, bytes.length, Endian.big);
    offset += 4;
    // Copy proto payload into the output buffer.
    final view = buffer.buffer.asUint8List();
    view.setRange(offset, offset + bytes.length, bytes);
    offset += bytes.length;
  }

  return buffer.buffer.asUint8List();
}

/// Decode a [Uint8List] of length-delimited [TelemetryFrame]s back into a
/// list.  This is the inverse of [encodeRawFrames].
List<TelemetryFrame> decodeRawFrames(Uint8List data) {
  final frames = <TelemetryFrame>[];
  final view = ByteData.sublistView(data);
  var offset = 0;

  while (offset < data.length) {
    if (offset + 4 > data.length) break; // Truncated header — stop gracefully.
    final length = view.getUint32(offset, Endian.big);
    offset += 4;

    if (offset + length > data.length) break; // Truncated payload.
    final frameBytes = data.sublist(offset, offset + length);
    frames.add(TelemetryFrame.fromBuffer(frameBytes));
    offset += length;
  }

  return frames;
}
