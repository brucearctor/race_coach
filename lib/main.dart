import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'package:race_coach/features/session/data/db/db_migrator.dart';
import 'package:race_coach/src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait and set system UI style for a dark cockpit-style look.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Clear any stale BLE connections from a previous Dart instance
  // (e.g. hot restart). The native BLE layer can hold connections
  // that the Dart VM no longer tracks.
  FlutterReactiveBle().deinitialize();

  // Initialize Rust analysis core via flutter_rust_bridge.
  await RustLib.init();

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create a shared container so the migrator and the app share providers.
  final container = ProviderContainer();

  // Migrate existing protobuf sessions into the Drift DB index.
  // Best-effort — if it fails, the app still works (filesystem is truth).
  try {
    final migrator = container.read(dbMigratorProvider);
    await migrator.migrateIfNeeded();
  } catch (e) {
    debugPrint('[main] DB migration failed (will retry next launch): $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RaceCoachApp(),
    ),
  );
}
