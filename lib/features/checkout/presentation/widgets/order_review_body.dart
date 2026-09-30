import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_review_card.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_summary.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_review_card.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/section_title.dart';

class OrderReviewBody extends StatelessWidget {
  const OrderReviewBody({super.key, this.onEditStep});

  final ValueChanged<int>? onEditStep;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final address = cubit.address;
    final paymentOption = cubit.paymentOption;
    final subtotal = cubit.subtotal;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.h,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.h,
            children: [
              SectionTitle(title: AppStrings.orderSummary),
              OrderSummary(
                shippingCost: paymentOption.shippingCost,
                subtotal: subtotal,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.h,
            children: [
              SectionTitle(
                title: AppStrings.paymentMethod,
                onActionTap: () => onEditStep?.call(1),
              ),
              PaymentReviewCard(paymentOption: paymentOption),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.h,
            children: [
              SectionTitle(
                title: AppStrings.deliveryAddress,
                onActionTap: () => onEditStep?.call(0),
              ),
              AddressReviewCard(address: address),
            ],
          ),
        ],
      ),
    );
  }
}
