import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class ProductsResetSortButton extends StatelessWidget {
  const ProductsResetSortButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8.r),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        spacing: 4.w,
        children: [
          Icon(
            Icons.restart_alt_rounded,
            size: 18.sp,
            color: context.colors.subText,
          ),
          Text(
            AppStrings.reset,
            style: AppTextStyles.font13SemiBold.copyWith(
              color: context.colors.subText,
            ),
          ),
        ],
      ),
    ),
  );
}
