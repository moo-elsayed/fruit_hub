import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_language_cubit.dart';
import 'package:fruit_hub/core/theming/app_theme_cubit.dart';
import 'package:fruit_hub/core/utils/custom_bottom_sheet_selection_item.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_card.dart';

// --------------- Language ---------------

List<CustomBottomSheetSelectionItem<String>> _getLanguageItems(
  BuildContext context,
) => [
  CustomBottomSheetSelectionItem<String>(
    title: AppStrings.arabic,
    icon: Icons.language_rounded,
    value: 'ar',
    isSelected: context.isArabic,
    onTap: () => context.read<AppLanguageCubit>().changeLanguage('ar'),
  ),
  CustomBottomSheetSelectionItem<String>(
    title: AppStrings.english,
    icon: Icons.language_rounded,
    value: 'en',
    isSelected: !context.isArabic,
    onTap: () => context.read<AppLanguageCubit>().changeLanguage('en'),
  ),
];

// --------------- Theme ---------------

String _themeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.light => AppStrings.light,
  ThemeMode.dark => AppStrings.dark,
  ThemeMode.system => AppStrings.system,
};

List<CustomBottomSheetSelectionItem<ThemeMode>> _getThemeItems(
  BuildContext context,
) {
  final currentTheme = context.read<AppThemeCubit>().state;
  return [
    CustomBottomSheetSelectionItem<ThemeMode>(
      title: AppStrings.light,
      icon: Icons.wb_sunny_outlined,
      value: ThemeMode.light,
      isSelected: currentTheme == ThemeMode.light,
      onTap: () => context.read<AppThemeCubit>().changeTheme(ThemeMode.light),
    ),
    CustomBottomSheetSelectionItem<ThemeMode>(
      title: AppStrings.dark,
      icon: Icons.nightlight_round_outlined,
      value: ThemeMode.dark,
      isSelected: currentTheme == ThemeMode.dark,
      onTap: () => context.read<AppThemeCubit>().changeTheme(ThemeMode.dark),
    ),
    CustomBottomSheetSelectionItem<ThemeMode>(
      title: AppStrings.system,
      icon: Icons.brightness_auto_outlined,
      value: ThemeMode.system,
      isSelected: currentTheme == ThemeMode.system,
      onTap: () => context.read<AppThemeCubit>().changeTheme(ThemeMode.system),
    ),
  ];
}

// --------------- Profile Items ---------------

List<ProfileCardItem> getProfileItems(BuildContext context) => [
  ProfileCardItem(
    icon: Icons.inventory_2_outlined,
    title: AppStrings.myOrders,
    onTap: () => context.pushNamed(Routes.ordersView),
  ),
  ProfileCardItem(
    icon: Icons.language_rounded,
    title: AppStrings.language,
    trailingText: context.isArabic ? AppStrings.arabic : AppStrings.english,
    onTap: () => CustomBottomSheet.show(
      context: context,
      title: AppStrings.selectLanguage,
      items: _getLanguageItems(context),
    ),
  ),
  ProfileCardItem(
    icon: Icons.color_lens_outlined,
    title: AppStrings.theme,
    trailingText: _themeLabel(context.read<AppThemeCubit>().state),
    onTap: () => CustomBottomSheet.show(
      context: context,
      title: AppStrings.theme,
      items: _getThemeItems(context),
    ),
  ),
];
