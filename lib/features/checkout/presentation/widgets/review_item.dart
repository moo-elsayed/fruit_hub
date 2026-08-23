import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';

class ReviewItem extends StatelessWidget {
  const ReviewItem({
    super.key,
    required this.title,
    required this.value,
    required this.onEditTap,
    required this.icon,
  });

  final String title;
  final String value;
  final Widget icon;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
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
            onTap: onEditTap,
            child: Text(
              'edit'.tr(),
              style: AppTextStyles.font13Bold.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
      Gap(8.h),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            SizedBox(height: 24.h, width: 24.w, child: icon),
            Gap(12.w),
            Expanded(
              child: Text(
                value,
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
