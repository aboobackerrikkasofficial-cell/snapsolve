import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapsolve_ai/widgets/premium_core.dart';

void main() {
  testWidgets('PremiumButton displays child and handles taps', (WidgetTester tester) async {
    bool tapped = false;

    // Build the PremiumButton widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PremiumButton(
            onPressed: () {
              tapped = true;
            },
            child: const Text('Submit Solution'),
          ),
        ),
      ),
    );

    // Verify that the child text is displayed
    expect(find.text('Submit Solution'), findsOneWidget);

    // Tap the button and verify the callback is executed
    await tester.tap(find.text('Submit Solution'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
