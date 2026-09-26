import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('MainScreenHeader Widget Tests', () {
    testWidgets('should render title correctly without action by default', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const MainScreenHeader(title: 'Cart')),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cart'), findsOneWidget);
    });

    testWidgets('should render action widget when provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const MainScreenHeader(
            title: 'Cart',
            action: Icon(Icons.shopping_bag, key: Key('cart_action_icon')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cart'), findsOneWidget);
      expect(find.byKey(const Key('cart_action_icon')), findsOneWidget);
    });
  });
}
