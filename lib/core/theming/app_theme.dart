import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  // ☀️ Light Theme
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppPalette.primaryGreen,
    scaffoldBackgroundColor: AppPalette.bgLight,
    useMaterial3: true,
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.bgLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppPalette.bgLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(color: AppPalette.textMainLight),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        color: AppPalette.textMainLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.primaryGreen,
      brightness: Brightness.light,
      primary: AppPalette.primaryGreen,
      surface: AppPalette.surfaceLight,
      onSurface: AppPalette.textMainLight,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppPalette.surfaceLight,
      surfaceTintColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // 🌙 Dark Theme
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppPalette.primaryGreenDark,
    scaffoldBackgroundColor: AppPalette.bgDark,
    useMaterial3: true,
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.bgDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppPalette.bgDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: AppPalette.textMainDark),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        color: AppPalette.textMainDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppPalette.primaryGreenDark,
          brightness: Brightness.dark,
          primary: AppPalette.primaryGreenDark,
          surface: AppPalette.surfaceDark,
          onSurface: AppPalette.textMainDark,
        ).copyWith(
          surface: AppPalette.surfaceDark,
          surfaceTint: Colors.transparent,
        ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppPalette.surfaceDark,
      surfaceTintColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
