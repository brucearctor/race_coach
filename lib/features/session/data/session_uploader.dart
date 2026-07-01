import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:race_coach/features/auth/data/auth_service.dart';
import 'package:race_coach/features/session/data/session_storage.dart';
import 'package:race_coach/generated/racecoach/v1/session.pb.dart';

// =============================================================================
// Riverpod Providers
// =============================================================================

/// Provides a [SessionUploader] instance.
final sessionUploaderProvider = Provider<SessionUploader>((ref) {
  return SessionUploader(
    auth: ref.watch(firebaseAuthProvider),
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

// =============================================================================
// SessionUploader
// =============================================================================

/// Uploads recorded sessions to Firebase Cloud Storage and creates
/// corresponding metadata documents in Firestore.
///
/// Storage layout:
///   `sessions/{userId}/{sessionId}/session.pb`
///   `sessions/{userId}/{sessionId}/raw_frames.pb`
///
/// Firestore layout:
///   `users/{userId}/sessions/{sessionId}` — metadata document
class SessionUploader {
  SessionUploader({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _auth = auth,
       _firestore = firestore,
       _storage = storage;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // ---------------------------------------------------------------------------
  // Upload a session
  // ---------------------------------------------------------------------------

  /// Uploads session files (session.pb + raw_frames.pb) to Cloud Storage
  /// and creates a Firestore metadata document.
  ///
  /// Throws [StateError] if the user is not signed in.
  /// Throws [FileSystemException] if local session files are missing.
  Future<void> uploadSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to upload sessions.');
    }

    final userId = user.uid;
    final sessionDir = await _sessionDirectory(sessionId);

    // Read local files.
    final sessionFile = File('${sessionDir.path}/session.pb');
    final rawFramesFile = File('${sessionDir.path}/raw_frames.pb');

    if (!sessionFile.existsSync()) {
      throw FileSystemException('session.pb not found', sessionFile.path);
    }

    // Parse session proto for metadata.
    final sessionBytes = await sessionFile.readAsBytes();
    final session = Session.fromBuffer(sessionBytes);

    // Upload session.pb to Cloud Storage.
    final storagePath = 'sessions/$userId/$sessionId';
    final sessionRef = _storage.ref('$storagePath/session.pb');
    await sessionRef.putFile(
      sessionFile,
      SettableMetadata(contentType: 'application/x-protobuf'),
    );

    // Upload raw_frames.pb if it exists.
    if (rawFramesFile.existsSync()) {
      final rawRef = _storage.ref('$storagePath/raw_frames.pb');
      await rawRef.putFile(
        rawFramesFile,
        SettableMetadata(contentType: 'application/x-protobuf'),
      );
    }

    // Upload meta.pb if it exists.
    final metaFile = File('${sessionDir.path}/meta.pb');
    SessionMeta? meta;
    if (metaFile.existsSync()) {
      final metaRef = _storage.ref('$storagePath/meta.pb');
      await metaRef.putFile(
        metaFile,
        SettableMetadata(contentType: 'application/x-protobuf'),
      );
      try {
        meta = SessionMeta.fromBuffer(await metaFile.readAsBytes());
      } catch (_) {
        // Corrupted meta — upload the file but skip Firestore merge.
      }
    }

    // Derive metadata from session proto.
    DateTime sessionDate;
    if (session.hasStartTime()) {
      sessionDate = DateTime.fromMillisecondsSinceEpoch(
        session.startTime.seconds.toInt() * 1000 +
            session.startTime.nanos ~/ 1000000,
      );
    } else {
      sessionDate = SessionStorage.parseDateFromId(sessionId);
    }

    // Find best lap time in milliseconds.
    int? bestLapMs;
    for (final lap in session.laps) {
      if (lap.lapTimeSeconds <= 0) continue;
      final ms = (lap.lapTimeSeconds * 1000).round();
      if (bestLapMs == null || ms < bestLapMs) {
        bestLapMs = ms;
      }
    }

    // Create / update Firestore metadata document.
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId);

    final firestoreData = <String, dynamic>{
      'trackName': session.trackName,
      'date': Timestamp.fromDate(sessionDate),
      'lapCount': session.laps.length,
      'bestLapMs': bestLapMs,
      'uploadedAt': FieldValue.serverTimestamp(),
      'storagePath': storagePath,
    };

    // Merge session metadata fields if meta.pb was present.
    if (meta != null) {
      if (meta.driverName.isNotEmpty) {
        firestoreData['driverName'] = meta.driverName;
      }
      if (meta.vehicle.name.isNotEmpty) {
        firestoreData['vehicleName'] = meta.vehicle.name;
      }
      if (meta.vehicle.make.isNotEmpty) {
        firestoreData['vehicleMake'] = meta.vehicle.make;
      }
      if (meta.vehicle.model.isNotEmpty) {
        firestoreData['vehicleModel'] = meta.vehicle.model;
      }
      if (meta.conditions.surface !=
          SurfaceCondition.SURFACE_CONDITION_UNSPECIFIED) {
        firestoreData['surface'] = meta.conditions.surface.name;
      }
      if (meta.sessionType != SessionType.SESSION_TYPE_UNSPECIFIED) {
        firestoreData['sessionType'] = meta.sessionType.name;
      }
      if (meta.notes.isNotEmpty) {
        firestoreData['notes'] = meta.notes;
      }
    }

    await docRef.set(firestoreData);
  }

  // ---------------------------------------------------------------------------
  // Query cloud sessions
  // ---------------------------------------------------------------------------

  /// Lists all uploaded sessions for the current user, ordered by date
  /// descending.
  ///
  /// Returns a list of maps matching the Firestore document fields.
  /// Throws [StateError] if the user is not signed in.
  Future<List<Map<String, dynamic>>> listCloudSessions() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to list cloud sessions.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['sessionId'] = doc.id;
      return data;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Check upload status
  // ---------------------------------------------------------------------------

  /// Returns `true` if the given [sessionId] has already been uploaded to
  /// Firestore for the current user.
  Future<bool> isUploaded(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .get();

    return doc.exists;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Resolves the local session directory path.
  Future<Directory> _sessionDirectory(String sessionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/sessions/$sessionId');
  }
}
