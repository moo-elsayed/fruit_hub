import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/product_badge.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('ProductBadge Widget Tests', () {
    testWidgets(
      'should render badge icon correctly without tooltip by default',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const ProductBadge(icon: Icons.eco, color: Colors.green),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Tooltip), findsNothing);
        expect(find.byIcon(Icons.eco), findsOneWidget);
        final icon = tester.widget<Icon>(find.byIcon(Icons.eco));
        expect(icon.color, Colors.green);
      },
    );

    testWidgets(
      'should wrap badge with Tooltip when tooltip string is provided',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const ProductBadge(
              icon: Icons.local_fire_department,
              color: Colors.red,
              tooltip: 'Popular Item',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
        final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
        expect(tooltip.message, equals('Popular Item'));
        final icon = tester.widget<Icon>(
          find.byIcon(Icons.local_fire_department),
        );
        expect(icon.color, Colors.red);
      },
    );
  });
}
