import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/review_item.dart';
import 'package:gap/gap.dart';
import '../../../../generated/assets.dart';
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

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CheckoutCubit>();
    if (cubit.address != null) {
      address = cubit.address!;
    }
    if (cubit.paymentOption != null) {
      paymentOption = cubit.paymentOption!;
    }
    subtotal = cubit.subtotal;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text("order_summary".tr(), style: AppTextStyles.font16color0C0D0DBold),
        Gap(12.h),
        OrderSummary(
          shippingCost: paymentOption.shippingCost,
          subtotal: subtotal,
        ),
        Gap(16.h),
        ReviewItem(
          title: "payment_method".tr(),
          value: paymentOption.option,
          icon: _getPaymentIcon(paymentOption),
          onEditTap: () => widget.pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
        ),
        Gap(16.h),
        ReviewItem(
          title: "delivery_address".tr(),
          value: address.formattedLocation,
          icon: SvgPicture.asset(Assets.iconsLocation),
          onEditTap: () => widget.pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _getPaymentIcon(PaymentOptionEntity paymentOption) =>
      paymentOption.option == "pay_by_paypal".tr()
      ? Image.asset(Assets.imagesPaypalIcon)
      : paymentOption.option == "pay_by_credit_card".tr()
      ? SvgPicture.asset(Assets.svgsCard)
      : Image.asset(Assets.imagesCash);
}
