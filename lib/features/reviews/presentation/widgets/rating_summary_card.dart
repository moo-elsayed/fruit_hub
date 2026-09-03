import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({
    super.key,
    required this.avgRating,
    required this.ratingCount,
    required this.reviews,
  });

  final num avgRating;
  final int ratingCount;
  final List<ReviewEntity> reviews;

  int _countForStar(int star) =>
      reviews.where((r) => r.rating.round() == star).length;

  double _ratioForStar(int star) {
    if (reviews.isEmpty) return 0.0;
    return _countForStar(star) / reviews.length;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.colors.surface
          : AppPalette.bgLightSecondary,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: context.colors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Average Rating & Stars Column
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              avgRating.toStringAsFixed(1),
              style: AppTextStyles.font32Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            Gap(4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) => Icon(
                  index < avgRating.floor()
                      ? Icons.star_rounded
                      : (index < avgRating
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded),
                  color: context.colors.starYellow,
                  size: 18.sp,
                ),
              ),
            ),
            Gap(6.h),
            Text(
              '$ratingCount ${ratingCount == 1 ? AppStrings.review : AppStrings.reviews}',
              style: AppTextStyles.font13Regular.copyWith(
                color: context.colors.subText,
              ),
            ),
          ],
        ),
        Gap(20.w),
        Container(
          width: 1.w,
          height: 90.h,
          color: context.colors.border.withValues(alpha: 0.8),
        ),
        Gap(16.w),
        // Breakdown Bars
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final star = 5 - i;
              final ratio = _ratioForStar(star);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: AppTextStyles.font12Medium.copyWith(
                        color: context.colors.mainText,
                      ),
                    ),
                    Gap(2.w),
                    Icon(
                      Icons.star_rounded,
                      size: 12.sp,
                      color: context.colors.starYellow,
                    ),
                    Gap(6.w),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6.h,
                          backgroundColor: context.colors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}
