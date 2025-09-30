import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'font_weight_helper.dart';

abstract class AppTextStyles {
  static TextStyle font13color949D9ERegular = TextStyle(
    fontSize: 13.sp,
    fontFamily: 'Cairo',
    color: AppColors.color949D9E,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font13color4E5556FSemiBold = TextStyle(
    fontSize: 13.sp,
    fontFamily: 'Cairo',
    color: AppColors.color4E5556,
    fontWeight: FontWeightHelper.semiBold,
  );

  static TextStyle font16WhiteBold = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'Cairo',
    color: AppColors.white,
    fontWeight: FontWeightHelper.bold,
  );

  static TextStyle font22color0C0D0DBold = TextStyle(
    fontSize: 22.sp,
    fontFamily: 'Cairo',
    color: AppColors.color0C0D0D,
    fontWeight: FontWeightHelper.bold,
  );
  static TextStyle font22color1B5E37Bold = TextStyle(
    fontSize: 22.sp,
    fontFamily: 'Cairo',
    color: AppColors.color1B5E37,
    fontWeight: FontWeightHelper.bold,
  );
  static TextStyle font22colorF4A91FBold = TextStyle(
    fontSize: 22.sp,
    fontFamily: 'Cairo',
    color: AppColors.colorF4A91F,
    fontWeight: FontWeightHelper.bold,
  );
}
