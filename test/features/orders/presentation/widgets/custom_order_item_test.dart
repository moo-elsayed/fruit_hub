import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/custom_order_item.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_card_header.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_customer_details.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_financial_summary.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_products_list.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_summary_bar.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const tAddress = AddressEntity(
    city: 'القاهرة',
    streetName: 'شارع التحرير',
    phone: '01012345678',
  );

  const tItems = [
    OrderItemEntity(
      name: 'تفاح أحمر',
      price: 40.0,
      quantity: 2,
      code: 'apple_01',
    ),
  ];

  const tLiveOrder = OrderEntity(
    orderId: 1001,
    status: OrderStatus.shipped,
    date: '2026-09-28T10:00:00Z',
    shippingAddress: tAddress,
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.cash,
      shippingCost: 30.0,
    ),
    orderItems: tItems,
    totalPrice: 110.0,
  );

  const tDeliveredOrder = OrderEntity(
    orderId: 1002,
    status: OrderStatus.delivered,
    date: '2026-09-28T10:00:00Z',
    shippingAddress: tAddress,
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.card,
      shippingCost: 30.0,
    ),
    orderItems: tItems,
    totalPrice: 110.0,
  );

  const tCancelledOrder = OrderEntity(
    orderId: 1003,
    status: OrderStatus.cancelled,
    date: '2026-09-28T10:00:00Z',
    shippingAddress: tAddress,
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.paypal,
      shippingCost: 30.0,
    ),
    orderItems: tItems,
    totalPrice: 110.0,
  );

  group('CustomOrderItem Widget Tests', () {
    testWidgets('should render OrderCardHeader and OrderSummaryBar initially', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const CustomOrderItem(orderEntity: tLiveOrder),
        ),
      );

      expect(find.byType(OrderCardHeader), findsOneWidget);
      expect(find.byType(OrderSummaryBar), findsOneWidget);
    });

    testWidgets('should expand and collapse details when toggle is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const SingleChildScrollView(
            child: CustomOrderItem(orderEntity: tLiveOrder),
          ),
        ),
      );

      // Initially details are collapsed
      expect(find.text(AppStrings.viewDetails), findsOneWidget);

      // Tap toggle to expand
      await tester.tap(find.text(AppStrings.viewDetails));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.hideDetails), findsOneWidget);
      expect(find.byType(OrderCustomerDetails), findsOneWidget);
      expect(find.byType(OrderProductsList), findsOneWidget);
      expect(find.byType(OrderFinancialSummary), findsOneWidget);

      // Tap toggle to collapse
      await tester.tap(find.text(AppStrings.hideDetails));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.viewDetails), findsOneWidget);
    });

    testWidgets(
      'should show trackOrder button with navigation icon when order is live',
      (tester) async {
        var navigated = false;

        await tester.pumpWidget(
          createWidgetForTesting(
            routes: {
              Routes.trackOrderView: (context) {
                navigated = true;
                return const Scaffold(body: Text('Track View'));
              },
            },
            child: const SingleChildScrollView(
              child: CustomOrderItem(orderEntity: tLiveOrder),
            ),
          ),
        );

        // Expand to see action button
        await tester.tap(find.text(AppStrings.viewDetails));
        await tester.pumpAndSettle();

        final buttonFinder = find.byType(CustomMaterialButton);
        expect(buttonFinder, findsOneWidget);
        expect(find.text(AppStrings.trackOrder), findsOneWidget);
        expect(find.byIcon(Icons.navigation_outlined), findsOneWidget);

        await tester.ensureVisible(buttonFinder);
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        expect(navigated, isTrue);
      },
    );

    testWidgets(
      'should show orderDetails button with receipt icon when order is delivered',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const SingleChildScrollView(
              child: CustomOrderItem(orderEntity: tDeliveredOrder),
            ),
          ),
        );

        // Expand
        await tester.tap(find.text(AppStrings.viewDetails));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.orderDetails), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
        expect(find.text(AppStrings.trackOrder), findsNothing);
      },
    );

    testWidgets(
      'should show orderDetails button with receipt icon when order is cancelled',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const SingleChildScrollView(
              child: CustomOrderItem(orderEntity: tCancelledOrder),
            ),
          ),
        );

        // Expand
        await tester.tap(find.text(AppStrings.viewDetails));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.orderDetails), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
        expect(find.text(AppStrings.trackOrder), findsNothing);
      },
    );
  });
}
