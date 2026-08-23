import 'package:easy_localization/easy_localization.dart';
import '../../../../core/helpers/app_assets.dart';

class BottomNavigationBarEntity {
  BottomNavigationBarEntity({
    required this.label,
    required this.outlineIcon,
    required this.filledIcon,
  });

  final String label;
  final String outlineIcon;
  final String filledIcon;
}

List<BottomNavigationBarEntity> get bottomNavigationBarItems => [
  BottomNavigationBarEntity(
    label: 'home'.tr(),
    outlineIcon: AppAssets.iconsHomeOutline,
    filledIcon: AppAssets.iconsHomeFilled,
  ),
  BottomNavigationBarEntity(
    label: 'products'.tr(),
    outlineIcon: AppAssets.iconsProductsOutline,
    filledIcon: AppAssets.iconsProductsFilled,
  ),
  BottomNavigationBarEntity(
    label: 'shopping_cart'.tr(),
    outlineIcon: AppAssets.iconsShoppingCartOutline,
    filledIcon: AppAssets.iconsShoppingCartFilled,
  ),
  BottomNavigationBarEntity(
    label: 'my_account'.tr(),
    outlineIcon: AppAssets.iconsProfileOutline,
    filledIcon: AppAssets.iconsProfileFilled,
  ),
];
