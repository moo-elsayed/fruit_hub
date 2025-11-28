import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(title, style: AppTextStyles.font16color0C0D0DBold),
            GestureDetector(
              onTap: onEditTap,
              child: Text(
                "edit".tr(),
                style: AppTextStyles.font13color1B5E37Bold.copyWith(
                  color: AppColors.color1B5E37,
                ),
              ),
            ),
          ],
        ),
        Gap(8.h),
        Container(
          padding: .symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.colorF7F7F7,
            borderRadius: .circular(12.r),
          ),
          child: Row(
            children: [
              SizedBox(height: 24.h, width: 24.w, child: icon),
              Gap(12.w),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.font13BlackSemiBold,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
