import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/features/live/presentation/widgets/lap_timer_widget.dart';

void main() {
  // ===========================================================================
  // LapTimerState
  // ===========================================================================

  group('LapTimerState', () {
    test('default constructor has zero lap count', () {
      const state = LapTimerState();
      expect(state.lapCount, 0);
    });

    test('default constructor has zero currentLapTime', () {
      const state = LapTimerState();
      expect(state.currentLapTime, Duration.zero);
    });

    test('default constructor has null bestLapTime', () {
      const state = LapTimerState();
      expect(state.bestLapTime, isNull);
    });

    test('default constructor has zero delta', () {
      const state = LapTimerState();
      expect(state.delta, Duration.zero);
    });

    test('default constructor has isRunning = false', () {
      const state = LapTimerState();
      expect(state.isRunning, isFalse);
    });

    test('constructor with named arguments sets all fields', () {
      final state = LapTimerState(
        currentLapTime: const Duration(seconds: 90),
        bestLapTime: const Duration(seconds: 85),
        lapCount: 3,
        delta: const Duration(seconds: 5),
        isRunning: true,
      );
      expect(state.currentLapTime, const Duration(seconds: 90));
      expect(state.bestLapTime, const Duration(seconds: 85));
      expect(state.lapCount, 3);
      expect(state.delta, const Duration(seconds: 5));
      expect(state.isRunning, isTrue);
    });

    group('copyWith', () {
      test('preserves all fields when no arguments given', () {
        final state = LapTimerState(
          currentLapTime: const Duration(seconds: 60),
          bestLapTime: const Duration(seconds: 55),
          lapCount: 2,
          delta: const Duration(seconds: 5),
          isRunning: true,
        );
        final copy = state.copyWith();
        expect(copy.currentLapTime, state.currentLapTime);
        expect(copy.bestLapTime, state.bestLapTime);
        expect(copy.lapCount, state.lapCount);
        expect(copy.delta, state.delta);
        expect(copy.isRunning, state.isRunning);
      });

      test('updates individual fields', () {
        const state = LapTimerState();
        final copy = state.copyWith(lapCount: 5, isRunning: true);
        expect(copy.lapCount, 5);
        expect(copy.isRunning, isTrue);
        expect(copy.currentLapTime, Duration.zero);
      });

      test('clearBest sets bestLapTime to null', () {
        final state = LapTimerState(bestLapTime: const Duration(seconds: 60));
        final copy = state.copyWith(clearBest: true);
        expect(copy.bestLapTime, isNull);
      });

      test('clearBest=false preserves bestLapTime', () {
        final state = LapTimerState(bestLapTime: const Duration(seconds: 60));
        final copy = state.copyWith(clearBest: false);
        expect(copy.bestLapTime, const Duration(seconds: 60));
      });
    });
  });

  // ===========================================================================
  // LapTimerNotifier — via ProviderContainer
  // ===========================================================================

  group('LapTimerNotifier', () {
    late ProviderContainer container;
    late LapTimerNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(lapTimerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has zero lap count', () {
      final state = container.read(lapTimerProvider);
      expect(state.lapCount, 0);
    });

    test('initial state has zero currentLapTime', () {
      final state = container.read(lapTimerProvider);
      expect(state.currentLapTime, Duration.zero);
    });

    test('initial state has null bestLapTime', () {
      final state = container.read(lapTimerProvider);
      expect(state.bestLapTime, isNull);
    });

    test('initial state is not running', () {
      final state = container.read(lapTimerProvider);
      expect(state.isRunning, isFalse);
    });

    // ── start() ────────────────────────────────────────────────────────

    test('start() changes isRunning to true', () {
      notifier.start();
      final state = container.read(lapTimerProvider);
      expect(state.isRunning, isTrue);
    });

    test('start() when already running does not reset state', () {
      notifier.start();

      // Wait a tiny bit so the internal timer ticks at least once.
      // Then start again — should be a no-op.
      notifier.start();

      final state = container.read(lapTimerProvider);
      expect(state.isRunning, isTrue);
    });

    // ── stop() ─────────────────────────────────────────────────────────

    test('stop() changes isRunning to false', () {
      notifier.start();
      notifier.stop();
      final state = container.read(lapTimerProvider);
      expect(state.isRunning, isFalse);
    });

    test('stop() when not running is safe (no-op)', () {
      notifier.stop();
      final state = container.read(lapTimerProvider);
      expect(state.isRunning, isFalse);
    });

    // ── reset() ────────────────────────────────────────────────────────

    test('reset() restores all fields to initial state', () {
      notifier.start();
      notifier.completeLap();
      notifier.reset();

      final state = container.read(lapTimerProvider);
      expect(state.lapCount, 0);
      expect(state.currentLapTime, Duration.zero);
      expect(state.bestLapTime, isNull);
      expect(state.delta, Duration.zero);
      expect(state.isRunning, isFalse);
    });

    test('reset() after stop restores initial state', () {
      notifier.start();
      notifier.stop();
      notifier.reset();

      final state = container.read(lapTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.lapCount, 0);
    });

    // ── completeLap() ──────────────────────────────────────────────────

    test('completeLap() increments lapCount', () {
      notifier.start();
      notifier.completeLap();

      final state = container.read(lapTimerProvider);
      expect(state.lapCount, 1);
    });

    test('completeLap() called twice increments lapCount to 2', () {
      notifier.start();
      notifier.completeLap();
      notifier.completeLap();

      final state = container.read(lapTimerProvider);
      expect(state.lapCount, 2);
    });

    test('completeLap() sets bestLapTime on first lap', () {
      notifier.start();
      notifier.completeLap();

      final state = container.read(lapTimerProvider);
      expect(state.bestLapTime, isNotNull);
    });

    test('completeLap() keeps isRunning true', () {
      notifier.start();
      notifier.completeLap();

      final state = container.read(lapTimerProvider);
      expect(state.isRunning, isTrue);
    });

    test('completeLap() resets currentLapTime to zero', () {
      notifier.start();
      notifier.completeLap();

      final state = container.read(lapTimerProvider);
      expect(state.currentLapTime, Duration.zero);
    });

    test('completeLap() resets delta to zero', () {
      notifier.start();
      notifier.completeLap();

      final state = container.read(lapTimerProvider);
      expect(state.delta, Duration.zero);
    });

    test('completeLap() does nothing when not running', () {
      // Don't call start().
      notifier.completeLap();

      final state = container.read(lapTimerProvider);
      expect(state.lapCount, 0);
      expect(state.bestLapTime, isNull);
    });

    test('completeLap() updates bestLapTime only if faster', () {
      // This test uses timing, so the "faster" lap is the one with less
      // elapsed wall-clock time between start/completeLap calls.
      // Both laps complete nearly instantly so they'll be ~equal, but the
      // best should always be the minimum.
      notifier.start();
      notifier.completeLap(); // Lap 1 — sets first best
      final bestAfterLap1 = container.read(lapTimerProvider).bestLapTime!;

      notifier.completeLap(); // Lap 2 — should update best if faster
      final bestAfterLap2 = container.read(lapTimerProvider).bestLapTime!;

      // Best should be <= lap 1's time (either same or faster).
      expect(bestAfterLap2, lessThanOrEqualTo(bestAfterLap1));
    });
  });

  // ===========================================================================
  // LapTimerWidget rendering
  // ===========================================================================

  group('LapTimerWidget', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LapTimerWidget())),
        ),
      );
      expect(find.byType(LapTimerWidget), findsOneWidget);
    });

    testWidgets('shows "LAP –" when no laps completed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LapTimerWidget())),
        ),
      );
      expect(find.text('LAP –'), findsOneWidget);
    });

    testWidgets('shows "BEST --:--.---" when no best lap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LapTimerWidget())),
        ),
      );
      expect(find.text('BEST --:--.---'), findsOneWidget);
    });

    testWidgets('shows timer_off icon when not running', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LapTimerWidget())),
        ),
      );
      expect(find.byIcon(Icons.timer_off_rounded), findsOneWidget);
    });

    testWidgets('shows initial lap time as 00:00.000', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LapTimerWidget())),
        ),
      );
      expect(find.text('00:00.000'), findsOneWidget);
    });

    testWidgets('shows trophy icon for best lap row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LapTimerWidget())),
        ),
      );
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });
  });

  // ===========================================================================
  // Construction tests
  // ===========================================================================

  group('LapTimerWidget construction', () {
    test('can be constructed with const', () {
      const widget = LapTimerWidget();
      expect(widget, isA<LapTimerWidget>());
    });
  });
}
