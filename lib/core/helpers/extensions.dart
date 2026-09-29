import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fruit_hub/core/theming/colors_manager.dart';
import 'package:intl/intl.dart';
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
  bool get isRTL => Directionality.of(this) == ui.TextDirection.rtl;
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
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

extension DateTimeExtension on DateTime {
  String toLocalizedDate(BuildContext context) {
    try {
      final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
      return DateFormat.yMMMMd(locale).format(this);
    } catch (_) {
      return toFormattedDate();
    }
  }

  String toFormattedDate({String pattern = 'dd/MM/yyyy'}) {
    try {
      return DateFormat(pattern).format(this);
    } catch (_) {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
    }
  }
}

extension StringDateExtension on String {
  DateTime? get toDateTime => DateTime.tryParse(this);

  String toLocalizedDate(BuildContext context) {
    if (isEmpty) return '';
    final parsed = toDateTime;
    if (parsed == null) return this;
    return parsed.toLocalizedDate(context);
  }

  String toFormattedDate({String pattern = 'dd/MM/yyyy'}) {
    if (isEmpty) return '';
    final parsed = toDateTime;
    if (parsed == null) return length > 10 ? substring(0, 10) : this;
    return parsed.toFormattedDate(pattern: pattern);
  }
}
