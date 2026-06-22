import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ble/presentation/device_scanner_screen.dart';
import '../../features/live/presentation/live_dashboard_screen.dart';
import '../../features/session/presentation/sessions_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// Named route paths used throughout the app.
abstract class AppRoutes {
  static const String dashboard = '/';
  static const String deviceScanner = '/scanner';
  static const String sessions = '/sessions';
  static const String settings = '/settings';
}

/// Provides the [GoRouter] instance to the widget tree via Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const LiveDashboardScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.deviceScanner,
        name: 'deviceScanner',
        builder: (BuildContext context, GoRouterState state) {
          return const DeviceScannerScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.sessions,
        name: 'sessions',
        builder: (BuildContext context, GoRouterState state) {
          return const SessionsScreen();
        },
      ),
    ],
  );
});
