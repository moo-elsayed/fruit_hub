import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/profile/presentation/views/favorites_view.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/change_language_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

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
    leadingAsset: AppAssets.iconsHeart,
    titleText: AppStrings.favorites,
    onTap: () {
      PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
        context,
        settings: const RouteSettings(name: Routes.favoritesView),
        screen: const FavoritesView(),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    },
  ),
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
