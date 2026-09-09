import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class CartHeaderBadge extends StatelessWidget {
  const CartHeaderBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6.w,
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          size: 14.sp,
          color: context.colors.primary,
        ),
        Text(
          '$count ${AppStrings.products}',
          style: AppTextStyles.font12Bold.copyWith(
            color: context.colors.primary,
          ),
        ),
      ],
    ),
  );
}
