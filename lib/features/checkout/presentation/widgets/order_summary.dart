import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.shippingCost,
  });

  final double subtotal;
  final double shippingCost;

  double get total => subtotal + shippingCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.colorF7F7F7,
        borderRadius: .circular(12.r),
      ),
      child: Column(
        children: [
          _buildRow(
            title: "subtotal".tr(),
            value: "${getPrice(subtotal)} ${"pounds".tr()}",
          ),
          Gap(8.h),
          _buildRow(
            title: "shipping".tr(),
            value: shippingCost == 0
                ? "free".tr()
                : "${getPrice(shippingCost)} ${"pounds".tr()}",
            freeShipping: shippingCost == 0,
          ),
          Divider(color: AppColors.colorCACECE, thickness: 0.5, height: 30.h),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text("total".tr(), style: AppTextStyles.font16color0C0D0DBold),
              Text(
                "${getPrice(total)} ${"pounds".tr()}",
                style: AppTextStyles.font16color0C0D0DBold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required String value,
    bool freeShipping = false,
  }) => Row(
    mainAxisAlignment: .spaceBetween,
    children: [
      Text(title, style: AppTextStyles.font13BlackSemiBold),
      Text(
        value,
        style: freeShipping
            ? AppTextStyles.font13color3A8B33Bold
            : AppTextStyles.font13BlackSemiBold,
      ),
    ],
  );
}
