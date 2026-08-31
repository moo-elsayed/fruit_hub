import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_method_icon.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/review_item.dart';
import 'package:gap/gap.dart';
import 'order_summary.dart';

class ReviewBody extends StatelessWidget {
  const ReviewBody({super.key, required this.pageController});

  final PageController pageController;

  void _navigateToPage(int pageIndex) => pageController.animateToPage(
    pageIndex,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final address = cubit.address;
    final paymentOption = cubit.paymentOption;
    final subtotal = cubit.subtotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.orderSummary,
          style: AppTextStyles.font16Bold.copyWith(
            color: context.colors.mainText,
          ),
        ),
        Gap(12.h),
        OrderSummary(
          shippingCost: paymentOption.shippingCost,
          subtotal: subtotal,
        ),
        Gap(16.h),
        ReviewItem(
          title: AppStrings.paymentMethod,
          value: paymentOption.title,
          icon: PaymentMethodIcon(type: paymentOption.type),
          onEditTap: () => _navigateToPage(1),
        ),
        Gap(16.h),
        ReviewItem(
          title: AppStrings.deliveryAddress,
          value: address?.formattedLocation ?? '',
          icon: SvgPicture.asset(AppAssets.iconsLocation),
          onEditTap: () => _navigateToPage(0),
        ),
      ],
    );
  }
}
