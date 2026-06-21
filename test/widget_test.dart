import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:race_coach/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: RaceCoachApp()),
    );

    // Verify the app renders with the expected title in the app bar.
    expect(find.text('Race Coach'), findsOneWidget);
  });
}
