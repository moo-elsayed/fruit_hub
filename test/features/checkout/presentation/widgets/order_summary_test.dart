import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_summary.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_summary_row.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrderSummary Widget Tests', () {
    testWidgets(
      'should render subtotal, free shipping, and total correctly when shippingCost is 0',
      (tester) async {
        // Arrange
        const subtotal = 120.0;
        const shippingCost = 0.0;

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderSummary(
              subtotal: subtotal,
              shippingCost: shippingCost,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OrderSummaryRow), findsNWidgets(2));
        expect(find.text(AppStrings.subtotal), findsOneWidget);
        expect(find.text(AppStrings.shipping), findsOneWidget);
        expect(find.text(AppStrings.free), findsOneWidget);
        expect(find.text(AppStrings.total), findsOneWidget);
        // Both subtotal and total display the same price since shipping is free (0)
        expect(
          find.text('${subtotal.formattedPrice} ${AppStrings.pounds}'),
          findsNWidgets(2),
        );
      },
    );

    testWidgets(
      'should render formatted shipping cost when shippingCost is greater than 0',
      (tester) async {
        // Arrange
        const subtotal = 100.0;
        const shippingCost = 30.0;

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderSummary(
              subtotal: subtotal,
              shippingCost: shippingCost,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('${shippingCost.formattedPrice} ${AppStrings.pounds}'),
          findsOneWidget,
        );
        expect(
          find.text(
            '${(subtotal + shippingCost).formattedPrice} ${AppStrings.pounds}',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
