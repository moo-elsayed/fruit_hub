import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomMaterialButton Widget Tests', () {
    testWidgets(
      'should render text correctly and not show loading indicator by default',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomMaterialButton(onPressed: () {}, text: 'Submit'),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Submit'), findsOneWidget);
        expect(find.byType(MaterialButton), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      },
    );

    testWidgets('should trigger onPressed callback when button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool wasPressed = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomMaterialButton(
            onPressed: () => wasPressed = true,
            text: 'Click Me',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(CustomMaterialButton));

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets(
      'should show loading indicator and not trigger original onPressed when isLoading is true',
      (WidgetTester tester) async {
        // Arrange
        bool wasPressed = false;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomMaterialButton(
              onPressed: () => wasPressed = true,
              text: 'Loading',
              isLoading: true,
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

        // Act
        await tester.tap(find.byType(CustomMaterialButton));

        // Assert
        expect(wasPressed, isFalse);
      },
    );

    testWidgets(
      'should render icon correctly in trailing position by default and leading when configured',
      (WidgetTester tester) async {
        // Arrange & Act - Trailing icon (default)
        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomMaterialButton(
              onPressed: () {},
              text: 'Next',
              icon: const Icon(Icons.arrow_forward),
              isTrailingIcon: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);

        // Arrange & Act - Leading icon
        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomMaterialButton(
              onPressed: () {},
              text: 'Back',
              icon: const Icon(Icons.arrow_back),
              isTrailingIcon: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
      },
    );

    testWidgets('should render full width when maxWidth is set to true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomMaterialButton(
            onPressed: () {},
            text: 'Full Width',
            maxWidth: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final materialButton = tester.widget<MaterialButton>(
        find.byType(MaterialButton),
      );
      expect(materialButton.minWidth, equals(double.infinity));
    });

    testWidgets('should apply custom backgroundColor and textColor properly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomMaterialButton(
            onPressed: () {},
            text: 'Styled Button',
            backgroundColor: AppPalette.error,
            textColor: AppPalette.white,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final materialButton = tester.widget<MaterialButton>(
        find.byType(MaterialButton),
      );
      expect(materialButton.color, equals(AppPalette.error));

      final textWidget = tester.widget<Text>(find.text('Styled Button'));
      expect(textWidget.style?.color, equals(AppPalette.white));
    });
  });
}
