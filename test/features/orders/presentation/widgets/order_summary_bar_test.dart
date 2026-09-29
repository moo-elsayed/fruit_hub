import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_payment_type_chip.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_summary_bar.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrderSummaryBar Widget Tests', () {
    testWidgets('should render price, chip and collapsed viewDetails text', (
      tester,
    ) async {
      var toggled = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          child: OrderSummaryBar(
            totalPrice: 150.0,
            paymentType: PaymentMethodType.cash,
            isExpanded: false,
            onToggle: () => toggled = true,
          ),
        ),
      );

      expect(find.byType(CustomPriceText), findsOneWidget);
      expect(find.byType(OrderPaymentTypeChip), findsOneWidget);
      expect(find.text(AppStrings.viewDetails), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

      await tester.tap(find.text(AppStrings.viewDetails));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('should render hideDetails text when isExpanded is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: OrderSummaryBar(
            totalPrice: 200.0,
            paymentType: PaymentMethodType.card,
            isExpanded: true,
            onToggle: () {},
          ),
        ),
      );

      expect(find.text(AppStrings.hideDetails), findsOneWidget);
    });
  });

  group('OrderPaymentTypeChip Widget Tests', () {
    testWidgets('should render paypal chip correctly', (tester) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderPaymentTypeChip(
            paymentType: PaymentMethodType.paypal,
          ),
        ),
      );

      expect(find.text(AppStrings.payByPaypal), findsOneWidget);
      expect(find.byIcon(Icons.paypal), findsOneWidget);
    });

    testWidgets('should render card chip correctly', (tester) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderPaymentTypeChip(
            paymentType: PaymentMethodType.card,
          ),
        ),
      );

      expect(find.text(AppStrings.payByCreditCard), findsOneWidget);
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
    });

    testWidgets('should render cash chip correctly', (tester) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderPaymentTypeChip(
            paymentType: PaymentMethodType.cash,
          ),
        ),
      );

      expect(find.text(AppStrings.cashOnDelivery), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });
  });
}
