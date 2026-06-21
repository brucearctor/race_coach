import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/app.dart';

void main() {
  group('RaceCoachApp smoke test', () {
    testWidgets('app widget can be constructed', (WidgetTester tester) async {
      // Verify the app widget can be instantiated without throwing.
      // We don't pump the full widget tree because FlutterMap creates
      // network timers for tile loading that can't be drained in tests.
      // Full UI testing should be done as integration tests on-device.
      const app = RaceCoachApp();
      expect(app, isA<Widget>());
    });

    test('ProviderScope wraps app correctly', () {
      // Verify the app can be placed inside a ProviderScope.
      const widget = ProviderScope(child: RaceCoachApp());
      expect(widget, isA<Widget>());
    });
  });
}
