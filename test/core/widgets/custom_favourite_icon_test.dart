import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/custom_favourite_icon.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomFavouriteIcon Widget Tests', () {
    testWidgets('should render outlined heart when isFavourite is false', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomFavouriteIcon(isFavourite: false, onChanged: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const ValueKey('outlined')), findsOneWidget);
      expect(find.byKey(const ValueKey('filled')), findsNothing);
    });

    testWidgets('should render filled heart when isFavourite is true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomFavouriteIcon(isFavourite: true, onChanged: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const ValueKey('filled')), findsOneWidget);
      expect(find.byKey(const ValueKey('outlined')), findsNothing);
    });

    testWidgets(
      'should toggle visual state and trigger onChanged when tapped',
      (WidgetTester tester) async {
        // Arrange
        bool toggled = false;

        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomFavouriteIcon(
              isFavourite: false,
              onChanged: () => toggled = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(CustomFavouriteIcon));
        await tester.pumpAndSettle();

        // Assert
        expect(toggled, isTrue);
        expect(find.byKey(const ValueKey('filled')), findsOneWidget);
      },
    );

    testWidgets('should apply custom size and backgroundColor when provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomFavouriteIcon(
            isFavourite: false,
            onChanged: () {},
            size: 40,
            backgroundColor: Colors.blue,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomFavouriteIcon),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(container.constraints?.minWidth, equals(40));
      expect(container.constraints?.minHeight, equals(40));
      expect(decoration.color, equals(Colors.blue));
    });
  });
}
