import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final ReviewEntity review;

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.colors.surface
          : AppPalette.bgLightSecondary,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: context.colors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // User Avatar / Initials
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Center(
                child: Text(
                  _getInitials(review.name),
                  style: AppTextStyles.font14Bold.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          review.name.isNotEmpty
                              ? review.name
                              : AppStrings.welcome,
                          style: AppTextStyles.font14Bold.copyWith(
                            color: context.colors.mainText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Gap(6.w),
                      // Verified Buyer Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 11.sp,
                              color: context.colors.primary,
                            ),
                            Gap(2.w),
                            Text(
                              AppStrings.verifiedPurchase,
                              style: AppTextStyles.font11Regular.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (review.date.isNotEmpty) ...[
                    Gap(2.h),
                    Text(
                      review.date,
                      style: AppTextStyles.font11Regular.copyWith(
                        color: context.colors.subText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Star rating display
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 16.sp,
                  color: context.colors.starYellow,
                ),
              ),
            ),
          ],
        ),
        if (review.description.isNotEmpty) ...[
          Gap(10.h),
          Text(
            review.description,
            style: AppTextStyles.font13Regular.copyWith(
              color: context.colors.bodyText,
              height: 1.4,
            ),
          ),
        ],
      ],
    ),
  );
}
