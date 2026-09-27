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
            child: Text(
              AppStrings.changePassword,
              style: AppTextStyles.font14Medium.copyWith(
                color: colors.mainText,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.sp,
            color: colors.subText,
          ),
        ],
      ),
    );
  }
}
