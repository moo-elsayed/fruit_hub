import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_receipt_card.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const tAddress = AddressEntity(city: 'Cairo', streetName: 'Tahrir St');
  const tPaymentOption = PaymentOptionEntity(
    title: 'PayPal',
    type: PaymentMethodType.paypal,
    shippingCost: 0,
  );
  const tOrderEntity = OrderEntity(
    orderId: 1234,
    totalPrice: 150.0,
    paymentOption: tPaymentOption,
    shippingAddress: tAddress,
  );

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('OrderReceiptCard Widget Tests', () {
    testWidgets('should render order ID, payment method, and delivery address', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          withToastification: true,
          child: const SingleChildScrollView(
            child: OrderReceiptCard(orderEntity: tOrderEntity),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('#1234'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
      expect(find.text('Cairo, Tahrir St'), findsOneWidget);
      expect(find.textContaining(AppStrings.orderNumber), findsOneWidget);
    });

    testWidgets('should render copy icon and copy label for order ID', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          withToastification: true,
          child: const SingleChildScrollView(
            child: OrderReceiptCard(orderEntity: tOrderEntity),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.text(AppStrings.copy), findsOneWidget);
    });

    testWidgets('should render payment and location receipt row icons', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          withToastification: true,
          child: const SingleChildScrollView(
            child: OrderReceiptCard(orderEntity: tOrderEntity),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.payment_rounded), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });
  });
}
