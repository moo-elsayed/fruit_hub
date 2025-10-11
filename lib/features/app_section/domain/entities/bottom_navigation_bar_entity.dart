import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/assets.dart';

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
    label: "home".tr(),
    outlineIcon: Assets.iconsHomeOutline,
    filledIcon: Assets.iconsHomeFilled,
  ),
  BottomNavigationBarEntity(
    label: "products".tr(),
    outlineIcon: Assets.iconsProductsOutline,
    filledIcon: Assets.iconsProductsFilled,
  ),
  BottomNavigationBarEntity(
    label: "shopping_cart".tr(),
    outlineIcon: Assets.iconsShoppingCartOutline,
    filledIcon: Assets.iconsShoppingCartFilled,
  ),
  BottomNavigationBarEntity(
    label: "my_account".tr(),
    outlineIcon: Assets.iconsProfileOutline,
    filledIcon: Assets.iconsProfileFilled,
  ),
];
