import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildmart/shared/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('renders title, message, and icon properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your Cart is Empty',
              message:
                  'Looks like you haven\'t added any building materials yet.',
            ),
          ),
        ),
      );

      // Allow flutter_animate transitions to complete
      await tester.pumpAndSettle();

      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(
        find.text('Looks like you haven\'t added any building materials yet.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.remove_shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('renders action button and triggers callback when provided',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'No Products Found',
              message: 'Try adjusting your search filters.',
              buttonText: 'Browse Catalog',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Browse Catalog'), findsOneWidget);

      await tester.tap(find.text('Browse Catalog'));
      await tester.pump();

      expect(actionTriggered, isTrue);
    });
  });
}
