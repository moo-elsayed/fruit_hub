import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_review_content.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_review_item.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_summary.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_method_icon.dart';
import 'package:gap/gap.dart';

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
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.orderSummary,
            style: AppTextStyles.font16Bold.copyWith(
              color: context.colors.mainText,
            ),
          ),
          Gap(8.h),
          OrderSummary(
            shippingCost: paymentOption.shippingCost,
            subtotal: subtotal,
          ),
          Gap(16.h),
          OrderReviewItem(
            title: AppStrings.paymentMethod,
            value: paymentOption.title,
            icon: PaymentMethodIcon(type: paymentOption.type),
            onEditTap: () => onEditStep?.call(1),
          ),
          Gap(16.h),
          OrderReviewItem(
            crossAxisAlignment: CrossAxisAlignment.start,
            title: AppStrings.deliveryAddress,
            content: address != null
                ? AddressReviewContent(address: address)
                : null,
            value: address == null ? '' : null,
            icon: SvgPicture.asset(
              AppAssets.iconsLocation,
              colorFilter: ColorFilter.mode(
                context.colors.primary,
                BlendMode.srcIn,
              ),
            ),
            onEditTap: () => onEditStep?.call(0),
          ),
          Gap(16.h),
        ],
      ),
    );
  }
}
