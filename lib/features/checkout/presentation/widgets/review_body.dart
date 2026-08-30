import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/review_item.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/app_assets.dart';
import '../managers/checkout_cubit/checkout_cubit.dart';
import 'order_summary.dart';

class ReviewBody extends StatefulWidget {
  const ReviewBody({super.key, required this.pageController});

  final PageController pageController;

  @override
  State<ReviewBody> createState() => _ReviewBodyState();
}

class _ReviewBodyState extends State<ReviewBody> {
  late AddressEntity address;
  late PaymentOptionEntity paymentOption;
  late double subtotal;

  void _navigateToPage(int pageIndex) => widget.pageController.animateToPage(
    pageIndex,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CheckoutCubit>();
    if (cubit.address != null) {
      address = cubit.address!;
    }
    paymentOption = cubit.paymentOption;
    subtotal = cubit.subtotal;
  }

  @override
  Widget build(BuildContext context) => Column(
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
        icon: _getPaymentIcon(paymentOption),
        onEditTap: () => _navigateToPage(1),
      ),
      Gap(16.h),
      ReviewItem(
        title: AppStrings.deliveryAddress,
        value: address.formattedLocation,
        icon: SvgPicture.asset(AppAssets.iconsLocation),
        onEditTap: () => _navigateToPage(0),
      ),
    ],
  );

  Widget _getPaymentIcon(PaymentOptionEntity paymentOption) =>
      paymentOption.type == .paypal
      ? Image.asset(AppAssets.imagesPaypalIcon)
      : paymentOption.type == .card
      ? SvgPicture.asset(AppAssets.svgsCard)
      : Image.asset(AppAssets.imagesCash);
}
