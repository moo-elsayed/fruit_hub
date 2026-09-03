import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_summary_row.dart';
import 'package:gap/gap.dart';

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
      color: context.isDarkMode
          ? context.colors.surface
          : AppPalette.bgLightSecondary,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: context.colors.border),
    ),
    child: Column(
      children: [
        OrderSummaryRow(
          title: AppStrings.subtotal,
          value: '${subtotal.formattedPrice} ${AppStrings.pounds}',
        ),
        Gap(8.h),
        OrderSummaryRow(
          title: AppStrings.shipping,
          value: shippingCost == 0
              ? AppStrings.free
              : '${shippingCost.formattedPrice} ${AppStrings.pounds}',
          freeShipping: shippingCost == 0,
        ),
        Divider(color: context.colors.border, thickness: 0.5, height: 30.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.total,
              style: AppTextStyles.font16Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            Text(
              '${total.formattedPrice} ${AppStrings.pounds}',
              style: AppTextStyles.font16Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
