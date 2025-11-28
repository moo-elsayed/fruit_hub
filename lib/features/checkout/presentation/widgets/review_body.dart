import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/review_item.dart';
import 'package:gap/gap.dart';
import '../../../../generated/assets.dart';
import 'order_summary.dart';

class ReviewBody extends StatelessWidget {
  const ReviewBody({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text("order_summary".tr(), style: AppTextStyles.font16color0C0D0DBold),
        Gap(12.h),
        const OrderSummary(shippingCost: 0, subtotal: 100),
        Gap(16.h),
        ReviewItem(
          title: "payment_method".tr(),
          value: "pay_by_paypal".tr(),
          icon: Image.asset(Assets.imagesPaypalIcon),
          onEditTap: () => pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
        ),
        Gap(16.h),
        ReviewItem(
          title: "delivery_address".tr(),
          value: "شارع النيل، مبنى رقم 123، القاهرة",
          icon: SvgPicture.asset(Assets.iconsLocation),
          onEditTap: () => pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}
