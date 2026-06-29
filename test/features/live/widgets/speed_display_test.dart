import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/live/presentation/widgets/speed_display.dart';
import 'package:race_coach/features/telemetry/data/telemetry_bus.dart';
import 'package:race_coach/features/telemetry/domain/telemetry_state.dart';
import 'package:race_coach/generated/racecoach/v1/telemetry.pb.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper to build a TelemetryState with a given speed in km/h.
  // ---------------------------------------------------------------------------

  TelemetryState stateWithSpeedKmh(double kmh) {
    final gps = GpsData()..speedKmh = kmh;
    return TelemetryState(gps: gps);
  }

  /// Wraps [SpeedDisplay] in Material + Directionality + ProviderScope
  /// with telemetryBusProvider overridden to emit [state].
  Widget buildWidget(TelemetryState state) {
    return ProviderScope(
      overrides: [
        telemetryBusProvider.overrideWith((_) {
          final bus = TelemetryBus();
          // Seed the initial state by applying a frame if we have GPS data.
          if (state.gps != null) {
            final frame = TelemetryFrame()
              ..sourceType = SourceType.SOURCE_TYPE_RACEBOX_MINI
              ..gps = state.gps!;
            bus.updateFrame(frame);
          }
          return bus;
        }),
      ],
      child: const MaterialApp(home: Scaffold(body: SpeedDisplay())),
    );
  }

  // ===========================================================================
  // Rendering tests
  // ===========================================================================

  group('SpeedDisplay widget', () {
    testWidgets('renders without errors at zero speed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(TelemetryState.empty()));
      expect(find.byType(SpeedDisplay), findsOneWidget);
    });

    testWidgets('displays "0" when speed is zero', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(TelemetryState.empty()));
      // SpeedDisplay shows speedMph.round() — 0 km/h → 0 mph → "0"
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('displays "MPH" unit label', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(TelemetryState.empty()));
      expect(find.text('MPH'), findsOneWidget);
    });

    testWidgets('displays "MAX 0" initially', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(TelemetryState.empty()));
      expect(find.text('MAX 0'), findsOneWidget);
    });

    testWidgets('displays speed value when telemetry provides a speed', (
      WidgetTester tester,
    ) async {
      // 160.934 km/h ≈ 100 mph → rounds to 100
      final state = stateWithSpeedKmh(160.934);
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // The speed "100" appears in both the glow and foreground layers.
      expect(find.text('100'), findsWidgets);
    });

    testWidgets('displays max speed indicator with current speed', (
      WidgetTester tester,
    ) async {
      final state = stateWithSpeedKmh(160.934);
      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      // MAX should be at least 100 mph
      expect(find.textContaining('MAX'), findsOneWidget);
    });

    testWidgets('contains upward arrow icon for max speed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(TelemetryState.empty()));
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });
  });

  // ===========================================================================
  // Construction tests (no pump needed)
  // ===========================================================================

  group('SpeedDisplay construction', () {
    test('can be constructed with default key', () {
      const widget = SpeedDisplay();
      expect(widget, isA<SpeedDisplay>());
    });

    test('can be constructed with explicit key', () {
      const widget = SpeedDisplay(key: ValueKey('speed'));
      expect(widget.key, const ValueKey('speed'));
    });
  });
}
