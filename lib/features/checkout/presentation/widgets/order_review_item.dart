import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class OrderReviewItem extends StatelessWidget {
  const OrderReviewItem({
    super.key,
    required this.title,
    required this.onEditTap,
    required this.icon,
    this.value,
    this.content,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : assert(
         value != null || content != null,
         'Either value or content must be provided',
       );

  final String title;
  final String? value;
  final Widget? content;
  final Widget icon;
  final VoidCallback onEditTap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: crossAxisAlignment,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.font16Bold.copyWith(
              color: context.colors.mainText,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onEditTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Text(
                AppStrings.edit,
                style: AppTextStyles.font13Bold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      Gap(8.h),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? context.colors.surface
              : AppPalette.bgLightSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: SizedBox(height: 24.h, width: 24.w, child: icon),
            ),
            Gap(12.w),
            Expanded(
              child:
                  content ??
                  Text(
                    value!,
                    style: AppTextStyles.font13SemiBold.copyWith(
                      color: context.colors.mainText,
                    ),
                  ),
            ),
          ],
        ),
      ),
    ],
  );
}
