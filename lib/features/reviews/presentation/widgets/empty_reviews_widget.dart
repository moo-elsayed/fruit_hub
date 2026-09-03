import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class EmptyReviewsWidget extends StatelessWidget {
  const EmptyReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.starYellow.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 36.sp,
              color: context.colors.starYellow,
            ),
          ),
          Gap(16.h),
          Text(
            AppStrings.noReviewsYet,
            style: AppTextStyles.font16Bold.copyWith(
              color: context.colors.mainText,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(6.h),
          Text(
            AppStrings.beTheFirstToReview,
            style: AppTextStyles.font13Regular.copyWith(
              color: context.colors.subText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
