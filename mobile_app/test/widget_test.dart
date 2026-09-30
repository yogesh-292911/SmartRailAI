import 'package:flutter_test/flutter_test.dart';
import 'package:smart_rail/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartRailApp());

    // Verify that splash screen content is shown.
    expect(find.text('SmartRail'), findsOneWidget);
    expect(find.text('AI Track Asset Management'), findsOneWidget);

    // Pump the timer duration so the pending timer is processed.
    await tester.pump(const Duration(seconds: 2));
  });
}
