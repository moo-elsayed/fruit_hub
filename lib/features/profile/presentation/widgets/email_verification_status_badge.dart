import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class EmailVerificationStatusBadge extends StatelessWidget {
  const EmailVerificationStatusBadge({super.key, required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isVerified
            ? colors.primary.withValues(alpha: 0.1)
            : colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isVerified
              ? colors.primary.withValues(alpha: 0.25)
              : colors.error.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5.w,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 13.sp,
            color: isVerified ? colors.primary : colors.error,
          ),
          Text(
            isVerified
                ? AppStrings.verifiedAccount
                : AppStrings.pleaseVerifyYourEmail,
            style: AppTextStyles.font11SemiBold.copyWith(
              color: isVerified ? colors.primary : colors.error,
            ),
          ),
        ],
      ),
    );
  }
}
