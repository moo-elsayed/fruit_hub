import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';

class PaymentReviewCard extends StatelessWidget {
  const PaymentReviewCard({super.key, required this.paymentOption});

  final PaymentOptionEntity paymentOption;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.colors.surface
          : AppPalette.bgLightSecondary,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: context.colors.border),
    ),
    child: Row(
      spacing: 12.w,
      children: [
        SizedBox(
          height: 24.h,
          width: 24.w,
          child: switch (paymentOption.type) {
            .paypal => Image.asset(AppAssets.imagesPaypalIcon),
            .card => SvgPicture.asset(AppAssets.svgsCard),
            .cash => Image.asset(AppAssets.imagesCash),
          },
        ),
        Expanded(
          child: Text(
            paymentOption.title,
            style: AppTextStyles.font13SemiBold.copyWith(
              color: context.colors.mainText,
            ),
          ),
        ),
      ],
    ),
  );
}
