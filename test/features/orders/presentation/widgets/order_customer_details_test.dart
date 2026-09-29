import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_customer_details.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrderCustomerDetails Widget Tests', () {
    testWidgets(
      'should render shipping address and phone when phone is present',
      (tester) async {
        const address = AddressEntity(
          city: 'القاهرة',
          streetName: 'شارع التحرير',
          phone: '01012345678',
        );

        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderCustomerDetails(address: address),
          ),
        );

        expect(find.text(AppStrings.shippingAddress), findsOneWidget);
        expect(find.text(address.formattedLocation), findsOneWidget);
        expect(find.text('01012345678'), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
        expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      },
    );

    testWidgets('should not render phone row when phone is empty', (
      tester,
    ) async {
      const address = AddressEntity(
        city: 'الإسكندرية',
        streetName: 'شارع البحر',
        phone: '',
      );

      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderCustomerDetails(address: address),
        ),
      );

      expect(find.text(AppStrings.shippingAddress), findsOneWidget);
      expect(find.text(address.formattedLocation), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsNothing);
    });
  });
}
