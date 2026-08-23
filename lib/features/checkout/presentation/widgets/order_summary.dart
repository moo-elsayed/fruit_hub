import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';
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
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Column(
      children: [
        _buildRow(
          context: context,
          title: 'subtotal'.tr(),
          value: "${subtotal.formattedPrice} ${"pounds".tr()}",
        ),
        Gap(8.h),
        _buildRow(
          context: context,
          title: 'shipping'.tr(),
          value: shippingCost == 0
              ? 'free'.tr()
              : "${shippingCost.formattedPrice} ${"pounds".tr()}",
          freeShipping: shippingCost == 0,
        ),
        Divider(color: context.colors.border, thickness: 0.5, height: 30.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'total'.tr(),
              style: AppTextStyles.font16Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            Text(
              "${total.formattedPrice} ${"pounds".tr()}",
              style: AppTextStyles.font16Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildRow({
    required BuildContext context,
    required String title,
    required String value,
    bool freeShipping = false,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: AppTextStyles.font13SemiBold.copyWith(
          color: context.colors.mainText,
        ),
      ),
      Text(
        value,
        style: freeShipping
            ? AppTextStyles.font13Bold.copyWith(color: context.colors.primary)
            : AppTextStyles.font13SemiBold.copyWith(
                color: context.colors.mainText,
              ),
      ),
    ],
  );
}
