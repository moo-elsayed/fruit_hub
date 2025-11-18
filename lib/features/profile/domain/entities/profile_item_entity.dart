import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fruit_hub/features/profile/presentation/views/favorites_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../core/routing/routes.dart';
import '../../../../generated/assets.dart';
import '../../presentation/widgets/change_language_bottom_sheet.dart';

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
    leadingAsset: Assets.iconsHeart,
    titleText: "favorites".tr(),
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
    leadingAsset: Assets.iconsLanguageIcon,
    titleText: "language".tr(),
    trailingText: "app_language".tr(),
    onTap: () {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext sheetContext) =>
            const ChangeLanguageBottomSheet(),
      );
    },
  ),
];
