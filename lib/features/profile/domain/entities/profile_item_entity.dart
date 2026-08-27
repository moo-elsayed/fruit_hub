import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/change_language_bottom_sheet.dart';

class ProfileItemEntity {
  ProfileItemEntity({
    required this.leadingAsset,
    required this.titleText,
    this.trailingText,
    required this.onTap,
  });

  final String leadingAsset;
  final String titleText;
  final String? trailingText;
  final void Function() onTap;
}

List<ProfileItemEntity> getProfileItems(BuildContext context) => [
  ProfileItemEntity(
    leadingAsset: AppAssets.iconsLanguageIcon,
    titleText: AppStrings.language,
    trailingText: AppStrings.appLanguage,
    onTap: () {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext sheetContext) =>
            const ChangeLanguageBottomSheet(),
      );
    },
  ),
];
