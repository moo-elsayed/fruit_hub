import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/theming/colors_manager.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_summary_row.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrderSummaryRow Widget Tests', () {
    testWidgets(
      'should render title and value with default styling when freeShipping is false',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderSummaryRow(
              title: 'المجموع الفرعي',
              value: '150 جنيه',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('المجموع الفرعي'), findsOneWidget);
        expect(find.text('150 جنيه'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text('150 جنيه'));
        expect(textWidget.style?.color, equals(LightColors().mainText));
      },
    );

    testWidgets(
      'should render value with primary color when freeShipping is true',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderSummaryRow(
              title: 'التوصيل',
              value: 'مجاني',
              freeShipping: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('التوصيل'), findsOneWidget);
        expect(find.text('مجاني'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text('مجاني'));
        expect(textWidget.style?.color, equals(LightColors().primary));
      },
    );
  });
}
