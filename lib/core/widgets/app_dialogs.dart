import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../helpers/extensions.dart';
import '../theming/app_text_styles.dart';

abstract class AppDialogs {
  static void showLoadingDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30.h,
                  width: 30.w,
                  child: CupertinoActivityIndicator(
                    radius: 14.r,
                    color: context.colors.mainText,
                  ),
                ),
                Gap(16.h),
                Text(
                  'loading'.tr(),
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: context.colors.mainText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
