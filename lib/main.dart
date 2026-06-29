// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import 'app.dart';
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Lock to portrait and set system UI style for a dark cockpit-style look.
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//   ]);
//
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.light,
//     statusBarBrightness: Brightness.dark,
//     systemNavigationBarColor: Color(0xFF0D1117),
//     systemNavigationBarIconBrightness: Brightness.light,
//   ));
//
//   // Clear any stale BLE connections from a previous Dart instance
//   // (e.g. hot restart). The native BLE layer can hold connections
//   // that the Dart VM no longer tracks.
//   FlutterReactiveBle().deinitialize();
//
//   // Initialize Firebase.
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   runApp(
//     const ProviderScope(
//       child: RaceCoachApp(),
//     ),
//   );
// }
//

import 'package:flutter/material.dart';
import 'package:race_coach/src/rust/api/simple.dart';
import 'package:race_coach/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
            'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`',
          ),
        ),
      ),
    );
  }
}
