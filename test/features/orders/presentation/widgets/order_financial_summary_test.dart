import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_financial_summary.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrderFinancialSummary Widget Tests', () {
    testWidgets(
      'should render all financial rows with shipping cost when shippingCost > 0',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderFinancialSummary(
              subtotal: 120.0,
              shippingCost: 30.0,
              totalPrice: 150.0,
            ),
          ),
        );

        expect(find.text(AppStrings.subtotal), findsOneWidget);
        expect(find.text(AppStrings.delivery), findsOneWidget);
        expect(find.text(AppStrings.grandTotal), findsOneWidget);
        expect(find.byType(CustomPriceText), findsNWidgets(3));
        expect(find.text(AppStrings.freeShipping), findsNothing);
      },
    );

    testWidgets('should render freeShipping text when shippingCost is 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderFinancialSummary(
            subtotal: 200.0,
            shippingCost: 0.0,
            totalPrice: 200.0,
          ),
        ),
      );

      expect(find.text(AppStrings.subtotal), findsOneWidget);
      expect(find.text(AppStrings.delivery), findsOneWidget);
      expect(find.text(AppStrings.grandTotal), findsOneWidget);
      expect(find.text(AppStrings.freeShipping), findsOneWidget);
      // Only subtotal and totalPrice should have CustomPriceText
      expect(find.byType(CustomPriceText), findsNWidgets(2));
    });
  });
}
