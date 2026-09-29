import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/widgets/order_timeline_preview.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'order_card_header.dart';
import 'order_customer_details.dart';
import 'order_financial_summary.dart';
import 'order_products_list.dart';

class TrackOrderLoadingSkeleton extends StatelessWidget {
  const TrackOrderLoadingSkeleton({super.key});

  static const _dummyAddress = AddressEntity(
    city: 'Cairo',
    streetName: 'El-Tahrir Street',
    phone: '01012345678',
  );

  static const _dummyItems = [
    OrderItemEntity(
      name: 'Apple Red Delicious',
      price: 50,
      quantity: 2,
      code: '1234',
    ),
    OrderItemEntity(
      name: 'Fresh Orange Valencia',
      price: 30,
      quantity: 3,
      code: '5678',
    ),
  ];

  static const _dummyOrder = OrderEntity(
    orderId: 10001,
    date: '28 Sep 2026',
    status: OrderStatus.shipped,
    shippingAddress: _dummyAddress,
    paymentOption: PaymentOptionEntity(shippingCost: 30),
    totalPrice: 280,
    orderItems: _dummyItems,
  );

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: true,
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        spacing: 16.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderCardHeader(
            orderId: _dummyOrder.orderId,
            date: _dummyOrder.date,
            status: _dummyOrder.status,
          ),
          const OrderTimelinePreview(currentStep: 2),
          const OrderCustomerDetails(address: _dummyAddress),
          const OrderProductsList(products: _dummyItems),
          const OrderFinancialSummary(
            subtotal: 190,
            shippingCost: 30,
            totalPrice: 220,
          ),
        ],
      ),
    ),
  );
}
