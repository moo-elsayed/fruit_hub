import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_theme.dart';

Widget createWidgetForTesting({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  NavigatorObserver? navigatorObserver,
  Locale? locale,
  RouteFactory? onGenerateRoute,
  Map<String, WidgetBuilder>? routes,
}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, _) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: themeMode,
    locale: locale,
    onGenerateRoute: onGenerateRoute,
    routes: routes ?? const <String, WidgetBuilder>{},
    navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
    home: child is Scaffold ? child : Scaffold(body: child),
  ),
);
