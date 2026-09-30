import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/quantity_badge.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('QuantityBadge Widget Tests', () {
    testWidgets('should render quantity text correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const QuantityBadge(quantity: 3)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('x3'), findsOneWidget);
    });

    testWidgets('should apply custom colors when provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const QuantityBadge(
            quantity: 5,
            color: Colors.red,
            backgroundColor: Colors.yellow,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('x5'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('x5'));
      expect(textWidget.style?.color, Colors.red);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.yellow);
    });
  });
}
