import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // --- Clean Typography Getters (Cairo Font) ---
  static TextStyle get font10Bold =>
      GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w700);

  static TextStyle get font11Regular =>
      GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w400);

  static TextStyle get font11Medium =>
      GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w500);

  static TextStyle get font11SemiBold =>
      GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w600);

  static TextStyle get font12Regular =>
      GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w400);

  static TextStyle get font12Medium =>
      GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w500);

  static TextStyle get font12Bold =>
      GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700);

  static TextStyle get font13Regular =>
      GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w400);

  static TextStyle get font13Medium =>
      GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w500);

  static TextStyle get font13SemiBold =>
      GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w600);

  static TextStyle get font13Bold =>
      GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w700);

  static TextStyle get font14Regular =>
      GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w400);

  static TextStyle get font14Medium =>
      GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w500);

  static TextStyle get font14SemiBold =>
      GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600);

  static TextStyle get font14Bold =>
      GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w700);

  static TextStyle get font15Medium =>
      GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w500);

  static TextStyle get font15SemiBold =>
      GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w600);

  static TextStyle get font15Bold =>
      GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w700);

  static TextStyle get font15ExtraBold =>
      GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800);

  static TextStyle get font16Regular =>
      GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w400);

  static TextStyle get font16Medium =>
      GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w500);

  static TextStyle get font16SemiBold =>
      GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w600);

  static TextStyle get font16Bold =>
      GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w700);

  static TextStyle get font18Bold =>
      GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.w700);

  static TextStyle get font19Bold =>
      GoogleFonts.cairo(fontSize: 19.sp, fontWeight: FontWeight.w700);

  static TextStyle get font20Bold =>
      GoogleFonts.cairo(fontSize: 20.sp, fontWeight: FontWeight.w700);

  static TextStyle get font22Bold =>
      GoogleFonts.cairo(fontSize: 22.sp, fontWeight: FontWeight.w700);

  static TextStyle get font24Bold =>
      GoogleFonts.cairo(fontSize: 24.sp, fontWeight: FontWeight.w700);

  static TextStyle get font32Bold =>
      GoogleFonts.cairo(fontSize: 32.sp, fontWeight: FontWeight.w700);

  // --- Legacy Compatibility Styles ---
  static TextStyle get font11color1B5E37semiBold =>
      font11SemiBold.copyWith(color: AppColors.color1B5E37);

  static TextStyle get font13color949D9ERegular =>
      font13Regular.copyWith(color: AppColors.color949D9E);

  static TextStyle get font13color616A6BRegular =>
      font13Regular.copyWith(color: AppColors.color616A6B);

  static TextStyle get font13color4E5556Regular =>
      font13Regular.copyWith(color: AppColors.color4E5556);

  static TextStyle get font13color1B5E37Regular =>
      font13Regular.copyWith(color: AppColors.color1B5E37);

  static TextStyle get font13WhiteRegular =>
      font13Regular.copyWith(color: AppColors.white);

  static TextStyle get font13colorF4A91FRegular =>
      font13Regular.copyWith(color: AppColors.colorF4A91F);

  static TextStyle get font13color979899Regular =>
      font13Regular.copyWith(color: AppColors.color979899);

  static TextStyle get font13color7B7B7BRegular =>
      font13Regular.copyWith(color: AppColors.color7B7B7B);

  static TextStyle get font13GreyShade700Medium =>
      font13Medium.copyWith(color: AppColors.greyShade700);

  static TextStyle get font13color949D9ESemiBold =>
      font13SemiBold.copyWith(color: AppColors.color949D9E);

  static TextStyle get font13color4E5556SemiBold =>
      font13SemiBold.copyWith(color: AppColors.color4E5556);

  static TextStyle get font13color3A8B33SemiBold =>
      font13SemiBold.copyWith(color: AppColors.color3A8B33);

  static TextStyle get font13BlackSemiBold =>
      font13SemiBold.copyWith(color: AppColors.black);

  static TextStyle get font13colorAAAAAASemiBold =>
      font13SemiBold.copyWith(color: AppColors.colorAAAAAA);

  static TextStyle get font13color0C0D0DSemiBold =>
      font13SemiBold.copyWith(color: AppColors.color0C0D0D);

  static TextStyle get font13colorF4A91FSemiBold =>
      font13SemiBold.copyWith(color: AppColors.colorF4A91F);

  static TextStyle get font13colorF8C76DSemiBold =>
      font13SemiBold.copyWith(color: AppColors.colorF8C76D);

  static TextStyle get font13color4E5556FSemiBold =>
      font13SemiBold.copyWith(color: AppColors.color4E5556);

  static TextStyle get font13GreyShade600SemiBold =>
      font13SemiBold.copyWith(color: AppColors.greyShade600);

  static TextStyle get font13color2D9F5DSemiBold =>
      font13SemiBold.copyWith(color: AppColors.color2D9F5D);

  static TextStyle get font13color949D9EBold =>
      font13Bold.copyWith(color: AppColors.color949D9E);

  static TextStyle get font13color1B5E37Bold =>
      font13Bold.copyWith(color: AppColors.color1B5E37);

  static TextStyle get font13color3A8B33Bold =>
      font13Bold.copyWith(color: AppColors.color3A8B33);

  static TextStyle get font13color06161CBold =>
      font13Bold.copyWith(color: AppColors.color06161C);

  static TextStyle get font13colorF4A91FBold =>
      font13Bold.copyWith(color: AppColors.colorF4A91F);

  static TextStyle get font13color0C0D0DBold =>
      font13Bold.copyWith(color: AppColors.color0C0D0D);

  static TextStyle get font14color979899Medium =>
      font14Medium.copyWith(color: AppColors.color979899);

  static TextStyle get font16color949D9ERegular =>
      font16Regular.copyWith(color: AppColors.color949D9E);

  static TextStyle get font16color0C0D0DSemiBold =>
      font16SemiBold.copyWith(color: AppColors.color0C0D0D);

  static TextStyle get font16color616A6BSemiBold =>
      font16SemiBold.copyWith(color: AppColors.color616A6B);

  static TextStyle get font16color949D9ESemiBold =>
      font16SemiBold.copyWith(color: AppColors.color949D9E);

  static TextStyle get font16color1B5E37ESemiBold =>
      font16SemiBold.copyWith(color: AppColors.color1B5E37);

  static TextStyle get font16color1B5E37EBold =>
      font16Bold.copyWith(color: AppColors.color1B5E37);

  static TextStyle get font16color23AA49Bold =>
      font16Bold.copyWith(color: AppColors.color23AA49);

  static TextStyle get font16WhiteBold =>
      font16Bold.copyWith(color: AppColors.white);

  static TextStyle get font16color0C0D0DBold =>
      font16Bold.copyWith(color: AppColors.color0C0D0D);

  static TextStyle get font16color616A6BBold =>
      font16Bold.copyWith(color: AppColors.color616A6B);

  static TextStyle get font16color06140CBold =>
      font16Bold.copyWith(color: AppColors.color06140C);

  static TextStyle get font16RedBold =>
      font16Bold.copyWith(color: AppColors.red);

  static TextStyle get font19color0C0D0DBold =>
      font19Bold.copyWith(color: AppColors.color0C0D0D);

  static TextStyle get font19WhiteDBold =>
      font19Bold.copyWith(color: AppColors.white);

  static TextStyle get font22color0C0D0DBold =>
      font22Bold.copyWith(color: AppColors.color0C0D0D);

  static TextStyle get font22color1B5E37Bold =>
      font22Bold.copyWith(color: AppColors.color1B5E37);

  static TextStyle get font22colorF4A91FBold =>
      font22Bold.copyWith(color: AppColors.colorF4A91F);
}
