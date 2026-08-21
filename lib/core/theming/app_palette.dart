import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._();

  // --- Brand Colors (Derived from Fruit Hub #1B5E37) ---
  static const Color primaryGreen = Color(
    0xff1B5E37,
  ); // لون التطبيق الأساسي (أخضر داكن)
  static const Color primaryGreenLight = Color(
    0xff2D9F5D,
  ); // أخضر حيوي ومريح للعين
  static const Color primaryGreenDark = Color(
    0xff4ADE80,
  ); // أخضر ساطع عالي التباين للوضع الداكن
  static const Color secondaryGreen = Color(0xff23AA49); // لون أخضر ثانوي
  static const Color secondaryOrange = Color(
    0xffF4A91F,
  ); // لون ثانوي برتقالي / مانجو
  static const Color secondaryOrangeLight = Color(0xffF8C76D);

  // --- Accent & Status Colors ---
  static const Color accentGreen = Color(0xff10B981); // Emerald Green
  static const Color starYellow = Color(0xffF59E0B);
  static const Color error = Color(0xffEF4444);
  static const Color success = Color(0xff1B5E37);
  static const Color warning = Color(0xffF59E0B);
  static const Color info = Color(0xff3B82F6);

  // --- Common Colors ---
  static const Color white = Color(0xffFFFFFF);
  static const Color black = Color(0xff000000);

  // --- Backgrounds & Surfaces (Light Theme) ---
  static const Color bgLight = Color(0xffFFFFFF); // خلفية التطبيق الفاتحة
  static const Color bgLightSecondary = Color(0xffF9FAFA);
  static const Color surfaceLight = Color(0xffFFFFFF); // White Surface
  static const Color borderLight = Color(
    0xffE6E9EA,
  ); // Slate / Soft Grey Border

  // --- Backgrounds & Surfaces (Dark Theme) ---
  static const Color bgDark = Color(
    0xff06140C,
  ); // Deep Forest Dark (Midnight Green)
  static const Color surfaceDark = Color(0xff122419); // Dark Surface Container
  static const Color borderDark = Color(0xff23372A); // Dark Border

  // --- Text Colors (Light Theme) ---
  static const Color textMainLight = Color(0xff0C0D0D); // داكن عالي التباين
  static const Color textBodyLight = Color(0xff4E5556); // رمادي النصوص
  static const Color textSubLight = Color(
    0xff949D9E,
  ); // رمادي فاتح للنصوص الفرعية

  // --- Text Colors (Dark Theme) ---
  static const Color textMainDark = Color(
    0xffF8FAFC,
  ); // نصوص بيضاء عالية التباين
  static const Color textBodyDark = Color(0xffCBD5E1); // رمادي فاتح
  static const Color textSubDark = Color(0xff94A3B8); // رمادي متوسط

  // --- Tags & Status Chips ---
  static const Color tagConfirmedBgLight = Color(0xffEBF6EA);
  static const Color tagConfirmedTextLight = Color(0xff1B5E37);
  static const Color tagInProgressBgLight = Color(0xffFEF6E6);
  static const Color tagInProgressTextLight = Color(0xffF4A91F);

  static const Color tagConfirmedBgDark = Color(0x2623AA49);
  static const Color tagConfirmedTextDark = Color(0xff86EFAC);
  static const Color tagInProgressBgDark = Color(0x26F4A91F);
  static const Color tagInProgressTextDark = Color(0xffFCD34D);
}
