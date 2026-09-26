import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/custom_check_box.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomCheckBox Widget Tests', () {
    testWidgets('should render unchecked state without check icon by default', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomCheckBox(value: false, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('should render check icon when value is true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomCheckBox(value: true, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('should toggle value and trigger onChanged when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool currentValue = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          child: StatefulBuilder(
            builder: (context, setState) => CustomCheckBox(
              value: currentValue,
              onChanged: (val) {
                setState(() => currentValue = val);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(CustomCheckBox));
      await tester.pumpAndSettle();

      // Assert
      expect(currentValue, isTrue);
      expect(find.byType(SvgPicture), findsOneWidget);

      // Act again - uncheck
      await tester.tap(find.byType(CustomCheckBox));
      await tester.pumpAndSettle();

      // Assert
      expect(currentValue, isFalse);
      expect(find.byType(SvgPicture), findsNothing);
    });
  });
}
