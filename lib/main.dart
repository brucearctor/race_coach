import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait and set system UI style for a dark cockpit-style look.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF0D1117),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Clear any stale BLE connections from a previous Dart instance
  // (e.g. hot restart). The native BLE layer can hold connections
  // that the Dart VM no longer tracks.
  FlutterReactiveBle().deinitialize();

  runApp(
    const ProviderScope(
      child: RaceCoachApp(),
    ),
  );
}
