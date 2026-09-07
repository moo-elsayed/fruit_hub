import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
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

  String _formatDate(BuildContext context, String dateStr) {
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return DateFormat.yMMMMd(context.locale.languageCode).format(parsed);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.r),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: context.colors.border.withValues(alpha: 0.7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar (Image or Initial)
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.25),
                  width: 1.w,
                ),
              ),
              child: ClipOval(
                child: review.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: review.image,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            _getInitials(review.name),
                            style: AppTextStyles.font14Bold.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _getInitials(review.name),
                          style: AppTextStyles.font14Bold.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ),
              ),
            ),
            Gap(12.w),
            // User Name and Date/Badge
            Expanded(
              child: Column(
                spacing: 3.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.name.trim().isNotEmpty
                        ? review.name.trim()
                        : AppStrings.anonymousUser,
                    style: AppTextStyles.font14Bold.copyWith(
                      color: context.colors.mainText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (review.date.isNotEmpty) ...[
                        Text(
                          _formatDate(context, review.date),
                          style: AppTextStyles.font12Regular.copyWith(
                            color: context.colors.subText,
                          ),
                        ),
                        Gap(8.w),
                      ],
                      // Verified Buyer Badge
                      Row(
                        spacing: 3.w,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 13.sp,
                            color: context.colors.primary,
                          ),
                          Text(
                            AppStrings.verifiedPurchase,
                            style: AppTextStyles.font11Regular.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(8.w),
            // Stars Rating
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: context.colors.starYellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                spacing: 3.w,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14.sp,
                    color: context.colors.starYellow,
                  ),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: AppTextStyles.font12Bold.copyWith(
                      color: context.colors.mainText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.description.isNotEmpty) ...[
          Gap(12.h),
          Text(
            review.description,
            style: AppTextStyles.font13Regular.copyWith(
              color: context.colors.bodyText,
              height: 1.5,
            ),
          ),
        ],
      ],
    ),
  );
}
