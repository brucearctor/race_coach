import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/coaching/data/reference_lap_prefs.dart';

void main() {
  // ===========================================================================
  // ReferenceLapSelection — serialization
  // ===========================================================================

  group('ReferenceLapSelection', () {
    test('toJson produces expected keys', () {
      const selection = ReferenceLapSelection(
        sessionId: 'abc-123',
        lapNumber: 5,
      );

      final json = selection.toJson();

      expect(json['sessionId'], 'abc-123');
      expect(json['lapNumber'], 5);
      expect(json.keys.length, 2);
    });

    test('fromJson reconstructs selection', () {
      final json = <String, dynamic>{
        'sessionId': 'xyz-789',
        'lapNumber': 3,
      };

      final selection = ReferenceLapSelection.fromJson(json);

      expect(selection.sessionId, 'xyz-789');
      expect(selection.lapNumber, 3);
    });

    test('round-trip toJson → fromJson preserves data', () {
      const original = ReferenceLapSelection(
        sessionId: 'round-trip-test',
        lapNumber: 12,
      );

      final restored = ReferenceLapSelection.fromJson(original.toJson());

      expect(restored.sessionId, original.sessionId);
      expect(restored.lapNumber, original.lapNumber);
    });

    test('round-trip through JSON encode/decode', () {
      const original = ReferenceLapSelection(
        sessionId: 'json-encode-test',
        lapNumber: 7,
      );

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final restored = ReferenceLapSelection.fromJson(decoded);

      expect(restored.sessionId, original.sessionId);
      expect(restored.lapNumber, original.lapNumber);
    });
  });

  // ===========================================================================
  // ReferenceLapPrefs — file I/O with temp directory
  // ===========================================================================

  group('ReferenceLapPrefs (file I/O)', () {
    late Directory tempDir;
    late File prefsFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('reference_lap_prefs_test');
      prefsFile = File('${tempDir.path}/reference_laps.json');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    // Helper: create a prefs instance that uses our temp directory.
    // Since ReferenceLapPrefs uses path_provider internally, we test the
    // serialization logic directly by simulating what save/load does.

    test('serializes multiple tracks to JSON file', () {
      final prefs = <String, ReferenceLapSelection>{
        'laguna seca': const ReferenceLapSelection(
          sessionId: 'sess-1',
          lapNumber: 3,
        ),
        'thunderhill': const ReferenceLapSelection(
          sessionId: 'sess-2',
          lapNumber: 5,
        ),
      };

      // Simulate what _save does.
      final json = prefs.map((key, value) => MapEntry(key, value.toJson()));
      prefsFile.writeAsStringSync(jsonEncode(json));

      // Simulate what _load does.
      final content = prefsFile.readAsStringSync();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final loaded = decoded.map((key, value) => MapEntry(
            key,
            ReferenceLapSelection.fromJson(value as Map<String, dynamic>),
          ));

      expect(loaded.length, 2);
      expect(loaded['laguna seca']!.sessionId, 'sess-1');
      expect(loaded['laguna seca']!.lapNumber, 3);
      expect(loaded['thunderhill']!.sessionId, 'sess-2');
      expect(loaded['thunderhill']!.lapNumber, 5);
    });

    test('handles empty file gracefully', () {
      prefsFile.writeAsStringSync('{}');

      final content = prefsFile.readAsStringSync();
      final decoded = jsonDecode(content) as Map<String, dynamic>;

      expect(decoded, isEmpty);
    });

    test('handles corrupt JSON gracefully', () {
      prefsFile.writeAsStringSync('not valid json{{{');

      Map<String, ReferenceLapSelection> result = {};
      try {
        final content = prefsFile.readAsStringSync();
        final decoded = jsonDecode(content) as Map<String, dynamic>;
        result = decoded.map((key, value) => MapEntry(
              key,
              ReferenceLapSelection.fromJson(value as Map<String, dynamic>),
            ));
      } catch (e) {
        // Error should be caught — same as ReferenceLapPrefs._load().
        result = {};
      }

      expect(result, isEmpty);
    });

    test('overwrite preserves only updated data', () {
      // Initial save.
      final initial = <String, ReferenceLapSelection>{
        'track a': const ReferenceLapSelection(
          sessionId: 'old-sess',
          lapNumber: 1,
        ),
      };
      final json1 = initial.map((k, v) => MapEntry(k, v.toJson()));
      prefsFile.writeAsStringSync(jsonEncode(json1));

      // Update: add a new track, change existing.
      final updated = Map<String, ReferenceLapSelection>.of(initial);
      updated['track a'] = const ReferenceLapSelection(
        sessionId: 'new-sess',
        lapNumber: 4,
      );
      updated['track b'] = const ReferenceLapSelection(
        sessionId: 'sess-b',
        lapNumber: 2,
      );
      final json2 = updated.map((k, v) => MapEntry(k, v.toJson()));
      prefsFile.writeAsStringSync(jsonEncode(json2));

      // Re-load.
      final content = prefsFile.readAsStringSync();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final loaded = decoded.map((key, value) => MapEntry(
            key,
            ReferenceLapSelection.fromJson(value as Map<String, dynamic>),
          ));

      expect(loaded.length, 2);
      expect(loaded['track a']!.sessionId, 'new-sess');
      expect(loaded['track a']!.lapNumber, 4);
      expect(loaded['track b']!.sessionId, 'sess-b');
    });

    test('clear removes track from persisted data', () {
      final prefs = <String, ReferenceLapSelection>{
        'track a': const ReferenceLapSelection(
          sessionId: 'sess-1',
          lapNumber: 1,
        ),
        'track b': const ReferenceLapSelection(
          sessionId: 'sess-2',
          lapNumber: 2,
        ),
      };

      // Simulate clearSelection: copy, remove, save.
      final copy = Map<String, ReferenceLapSelection>.of(prefs);
      copy.remove('track a');
      final json = copy.map((k, v) => MapEntry(k, v.toJson()));
      prefsFile.writeAsStringSync(jsonEncode(json));

      // Re-load.
      final content = prefsFile.readAsStringSync();
      final decoded = jsonDecode(content) as Map<String, dynamic>;

      expect(decoded.containsKey('track a'), isFalse);
      expect(decoded.containsKey('track b'), isTrue);
    });
  });

  // ===========================================================================
  // Track name normalization
  // ===========================================================================

  group('Track name normalization', () {
    // Tests that the normalization logic (lowercase + trim) works.
    // We simulate _normalizeTrackName since it's private.
    String normalize(String name) => name.toLowerCase().trim();

    test('lowercases track name', () {
      expect(normalize('Laguna Seca'), 'laguna seca');
    });

    test('trims whitespace', () {
      expect(normalize('  Thunderhill  '), 'thunderhill');
    });

    test('combined case and whitespace', () {
      expect(normalize('  Road Atlanta  '), 'road atlanta');
    });

    test('already normalized name is unchanged', () {
      expect(normalize('sonoma'), 'sonoma');
    });

    test('same track with different casing normalizes to same key', () {
      expect(normalize('LAGUNA SECA'), normalize('laguna seca'));
      expect(normalize('Laguna Seca'), normalize('laguna seca'));
    });
  });
}
