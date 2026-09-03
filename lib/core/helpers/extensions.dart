import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fruit_hub/core/theming/colors_manager.dart';
import 'package:toastification/toastification.dart';

import 'app_strings.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed(routeName, arguments: arguments);

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
    bool rootNavigator = false,
  }) => Navigator.of(
    this,
    rootNavigator: rootNavigator,
  ).pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
}

extension AppToastColorExtension on ToastificationType {
  Color getColor(BuildContext context) => switch (this) {
    ToastificationType.success => context.colors.success,
    ToastificationType.info => context.colors.primary,
    ToastificationType.warning => context.colors.warning,
    ToastificationType.error => context.colors.error,
    _ => context.colors.primary,
  };
}

extension AppToastIconExtension on ToastificationType {
  IconData get stateIcon => switch (this) {
    ToastificationType.success => Icons.check_circle_outline_rounded,
    ToastificationType.error => Icons.error_outline_rounded,
    ToastificationType.warning => Icons.warning_amber_rounded,
    ToastificationType.info => Icons.info_outline_rounded,
    _ => Icons.info_outline_rounded,
  };
}

extension AppTheme on BuildContext {
  ColorsManager get colors => !isDarkMode ? LightColors() : DarkColors();
}

extension LanguageExtension on BuildContext {
  bool get isArabic {
    try {
      return locale.languageCode == 'ar';
    } catch (_) {
      return false;
    }
  }

  bool get isRTL => Directionality.of(this) == ui.TextDirection.rtl;
}

extension ThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  ThemeData get theme => Theme.of(this);
}

extension ThemeModeExtension on ThemeMode {
  String toText() {
    switch (this) {
      case ThemeMode.system:
        return AppStrings.system;
      case ThemeMode.light:
        return AppStrings.light;
      case ThemeMode.dark:
        return AppStrings.dark;
    }
  }
}

extension NumExtension on num {
  num get formattedPrice => toInt() == this ? toInt() : this;
}
