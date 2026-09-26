import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/custom_action_button.dart';
import 'package:fruit_hub/core/widgets/custom_quantity_selector.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomQuantitySelector Widget Tests', () {
    testWidgets('should render initial quantity correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomQuantitySelector(
            quantity: 3,
            onIncrement: () {},
            onDecrement: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('3'), findsOneWidget);
      expect(find.byType(CustomActionButton), findsNWidgets(2));
    });

    testWidgets('should trigger onIncrement when increment button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool incrementCalled = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomQuantitySelector(
            quantity: 1,
            onIncrement: () => incrementCalled = true,
            onDecrement: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      // The first CustomActionButton is increment (Plus)
      await tester.tap(find.byType(CustomActionButton).first);
      await tester.pumpAndSettle();

      // Assert
      expect(incrementCalled, isTrue);
    });

    testWidgets('should trigger onDecrement when decrement button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool decrementCalled = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomQuantitySelector(
            quantity: 2,
            onIncrement: () {},
            onDecrement: () => decrementCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      // The second CustomActionButton is decrement (Minus)
      await tester.tap(find.byType(CustomActionButton).last);
      await tester.pumpAndSettle();

      // Assert
      expect(decrementCalled, isTrue);
    });

    testWidgets(
      'should not trigger onIncrement or onDecrement when isEnabled is false',
      (WidgetTester tester) async {
        // Arrange
        bool incrementCalled = false;
        bool decrementCalled = false;

        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomQuantitySelector(
              quantity: 2,
              isEnabled: false,
              onIncrement: () => incrementCalled = true,
              onDecrement: () => decrementCalled = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(CustomActionButton).first);
        await tester.tap(find.byType(CustomActionButton).last);
        await tester.pumpAndSettle();

        // Assert
        expect(incrementCalled, isFalse);
        expect(decrementCalled, isFalse);
      },
    );

    testWidgets(
      'should not trigger onDecrement when isDecrementEnabled is false',
      (WidgetTester tester) async {
        // Arrange
        bool decrementCalled = false;

        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomQuantitySelector(
              quantity: 1,
              isDecrementEnabled: false,
              onIncrement: () {},
              onDecrement: () => decrementCalled = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(CustomActionButton).last);
        await tester.pumpAndSettle();

        // Assert
        expect(decrementCalled, isFalse);
      },
    );
  });
}
