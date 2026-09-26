import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_success_dialog.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomSuccessDialog Widget Tests', () {
    testWidgets('should render message text, success icon, and button', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomSuccessDialog(
            text: 'Your order was placed successfully!',
            buttonText: 'Done',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Your order was placed successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.byType(CustomMaterialButton), findsOneWidget);
    });

    testWidgets('should trigger onPressed when action button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomSuccessDialog(
            text: 'Operation completed',
            buttonText: 'Continue',
            onPressed: () => wasPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasPressed, isTrue);
    });
  });
}
