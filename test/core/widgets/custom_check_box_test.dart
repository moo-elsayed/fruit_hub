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
        createWidgetForTesting(child: const CustomCheckBox(value: false)),
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
        createWidgetForTesting(child: const CustomCheckBox(value: true)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('should update appearance when value changes', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetForTesting(child: const CustomCheckBox(value: false)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture), findsNothing);

      // Act - pump with value = true
      await tester.pumpWidget(
        createWidgetForTesting(child: const CustomCheckBox(value: true)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });
}
