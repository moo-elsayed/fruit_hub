import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_theme.dart';
import 'package:toastification/toastification.dart';

Widget createWidgetForTesting({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  NavigatorObserver? navigatorObserver,
  Locale? locale,
  RouteFactory? onGenerateRoute,
  Map<String, WidgetBuilder>? routes,
  bool withToastification = false,
}) => ScreenUtilInit(
  key: ValueKey('$themeMode-${locale?.languageCode}'),
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, _) {
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeMode == ThemeMode.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      onGenerateRoute: onGenerateRoute,
      routes: routes ?? const <String, WidgetBuilder>{},
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      home: child is Scaffold ? child : Scaffold(body: child),
    );
    return withToastification ? ToastificationWrapper(child: app) : app;
  },
);
