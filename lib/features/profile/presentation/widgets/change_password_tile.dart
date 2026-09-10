import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

import 'change_password_bottom_sheet.dart';

class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () => ChangePasswordBottomSheet.show(context),
      behavior: .opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        child: Row(
          spacing: 12.w,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: colors.primary,
                size: 20.sp,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 6.h,
                children: [
                  Text(
                    AppStrings.changePassword,
                    style: AppTextStyles.font14Medium.copyWith(
                      color: colors.mainText,
                    ),
                  ),
                  Row(
                    spacing: 5.w,
                    children: List.generate(
                      8,
                      (_) => Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: colors.subText.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: colors.subText,
            ),
          ],
        ),
      ),
    );
  }
}
