import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildmart/shared/widgets/buildmart_button.dart';

void main() {
  group('BuildMartButton Widget Tests', () {
    testWidgets('renders button text and triggers onPressed when tapped',
        (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BuildMartButton(
              text: 'Checkout Now',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Checkout Now'), findsOneWidget);

      await tester.tap(find.text('Checkout Now'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('renders CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BuildMartButton(
              text: 'Processing Order',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing Order'), findsNothing);
    });

    testWidgets('renders optional icon alongside label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BuildMartButton(
              text: 'Add to Cart',
              icon: Icons.shopping_bag_outlined,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
    });
  });
}
