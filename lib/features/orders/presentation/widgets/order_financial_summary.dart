import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:gap/gap.dart';

class OrderFinancialSummary extends StatelessWidget {
  const OrderFinancialSummary({
    super.key,
    required this.subtotal,
    required this.shippingCost,
    required this.totalPrice,
  });

  final double subtotal;
  final double shippingCost;
  final double totalPrice;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: context.colors.border, width: 0.8),
    ),
    child: Column(
      children: [
        _RowItem(
          title: AppStrings.subtotal,
          trailing: CustomPriceText(price: subtotal),
        ),
        Gap(6.h),
        _RowItem(
          title: AppStrings.delivery,
          trailing: shippingCost > 0
              ? CustomPriceText(price: shippingCost)
              : Text(
                  AppStrings.freeShipping,
                  style: AppTextStyles.font12Medium.copyWith(
                    color: context.colors.primary,
                  ),
                ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Divider(color: context.colors.border, height: 1),
        ),
        _RowItem(
          title: AppStrings.grandTotal,
          trailing: CustomPriceText(price: totalPrice, isLarge: true),
          isTotal: true,
        ),
      ],
    ),
  );
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.title,
    required this.trailing,
    this.isTotal = false,
  });

  final String title;
  final Widget trailing;
  final bool isTotal;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: isTotal
            ? AppTextStyles.font13Bold.copyWith(color: context.colors.mainText)
            : AppTextStyles.font12Medium.copyWith(
                color: context.colors.subText,
              ),
      ),
      trailing,
    ],
  );
}
