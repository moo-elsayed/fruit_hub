import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'font_weight_helper.dart';

abstract class AppStyles {
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

  static TextStyle font23color0C0D0DBold = TextStyle(
    fontSize: 23.sp,
    fontFamily: 'Cairo',
    color: AppColors.color0C0D0D,
    fontWeight: FontWeightHelper.bold,
  );
}
