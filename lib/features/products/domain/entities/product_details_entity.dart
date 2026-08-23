import 'package:easy_localization/easy_localization.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import '../../../../core/helpers/app_assets.dart';

class ProductDetailsEntity {
  ProductDetailsEntity({
    required this.title,
    required this.subtitle,
    required this.trailingAsset,
  });

  final String title;
  final String subtitle;
  final String trailingAsset;
}

List<ProductDetailsEntity> getProductDetails(FruitEntity fruitEntity) => [
  ProductDetailsEntity(
    title: "${fruitEntity.daysUntilExpiration} ${"days".tr()}",
    subtitle: 'validity'.tr(),
    trailingAsset: AppAssets.iconsCalendar,
  ),
  ProductDetailsEntity(
    title: '100%',
    subtitle: 'organic'.tr(),
    trailingAsset: AppAssets.iconsOrganic,
  ),
  ProductDetailsEntity(
    title: "${fruitEntity.numberOfCalories} ${"calories".tr()}",
    subtitle: "${fruitEntity.unitAmount} ${"gram".tr()}",
    trailingAsset: AppAssets.iconsCalory,
  ),
  ProductDetailsEntity(
    title: '${fruitEntity.avgRating} (${fruitEntity.reviews.length})',
    subtitle: 'reviews'.tr(),
    trailingAsset: AppAssets.iconsFavourites,
  ),
];
