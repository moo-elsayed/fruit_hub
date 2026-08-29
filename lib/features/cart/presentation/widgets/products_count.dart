import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class ProductsCount extends StatelessWidget {
  const ProductsCount({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
    width: double.infinity,
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: context.colors.border, width: 1.w),
      boxShadow: [
        BoxShadow(
          color: context.colors.mainText.withValues(alpha: 0.02),
          blurRadius: 8.r,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 16.sp,
            color: context.colors.primary,
          ),
        ),
        Gap(8.w),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${AppStrings.youHave} ',
                style: AppTextStyles.font13Medium.copyWith(
                  color: context.colors.mainText,
                ),
              ),
              TextSpan(
                text: '$count ',
                style: AppTextStyles.font14Bold.copyWith(
                  color: context.colors.primary,
                ),
              ),
              TextSpan(
                text: AppStrings.productsInTheShoppingCart,
                style: AppTextStyles.font13Medium.copyWith(
                  color: context.colors.mainText,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
