import 'package:flutter_test/flutter_test.dart';
import 'package:race_coach/src/rust/api/simple.dart';
import 'package:race_coach/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());

  test('Rust FFI round-trip works', () {
    expect(greet(name: 'Tom'), equals('Hello, Tom!'));
  });
}
