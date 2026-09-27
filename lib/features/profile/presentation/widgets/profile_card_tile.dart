import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/profile/presentation/items/profile_card_item.dart';

class ProfileCardTile extends StatelessWidget {
  const ProfileCardTile({
    super.key,
    required this.item,
    this.borderRadius = BorderRadius.zero,
  });

  final ProfileCardItem item;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: item.onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(item.icon, color: colors.primary, size: 18.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.font14Medium.copyWith(
                  color: colors.mainText,
                ),
              ),
            ),
            if (item.trailingText != null) ...[
              Text(
                item.trailingText!,
                style: AppTextStyles.font13Regular.copyWith(
                  color: colors.subText,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            if (item.trailingWidget != null) item.trailingWidget!,
            if (item.showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.subText,
                size: 14.sp,
              ),
          ],
        ),
      ),
    );
  }
}
