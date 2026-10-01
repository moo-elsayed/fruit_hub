import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/save_address.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  Widget buildTestWidget({
    bool value = true,
    required void Function(bool) onChanged,
  }) => createWidgetForTesting(
    child: SaveAddress(value: value, onChanged: onChanged),
  );

  group('SaveAddress Widget Tests', () {
    testWidgets('should render animated checkbox and saveAddress label', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(value: true, onChanged: (_) {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text(AppStrings.saveAddress), findsOneWidget);
    });

    testWidgets('should toggle value and invoke onChanged when tapped', (
      tester,
    ) async {
      // Arrange
      bool? updatedValue;
      await tester.pumpWidget(
        buildTestWidget(value: true, onChanged: (val) => updatedValue = val),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(SaveAddress));
      await tester.pumpAndSettle();

      // Assert
      expect(updatedValue, isFalse);

      // Act again
      await tester.tap(find.byType(SaveAddress));
      await tester.pumpAndSettle();

      // Assert
      expect(updatedValue, isTrue);
    });

    testWidgets('should update state when widget.value changes', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget(value: true, onChanged: (_) {}));
      await tester.pumpAndSettle();

      // Act - Rebuild with false
      await tester.pumpWidget(buildTestWidget(value: false, onChanged: (_) {}));
      await tester.pumpAndSettle();

      // Assert - Tap should now toggle from false to true
      bool? updatedValue;
      await tester.pumpWidget(
        buildTestWidget(value: false, onChanged: (val) => updatedValue = val),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SaveAddress));
      await tester.pumpAndSettle();

      expect(updatedValue, isTrue);
    });
  });
}
