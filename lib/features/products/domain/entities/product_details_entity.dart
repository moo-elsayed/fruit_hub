import 'package:fruit_hub/core/entities/fruit_entity.dart';
import '../../../../core/helpers/app_assets.dart';
import '../../../../core/helpers/app_strings.dart';

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
    title: '${fruitEntity.daysUntilExpiration} ${AppStrings.days}',
    subtitle: AppStrings.validity,
    trailingAsset: AppAssets.iconsCalendar,
  ),
  ProductDetailsEntity(
    title: '${fruitEntity.weightInGrams} ${AppStrings.gram}',
    subtitle: AppStrings.weight,
    trailingAsset: AppAssets.iconsScale,
  ),
  ProductDetailsEntity(
    title: '${fruitEntity.numberOfCalories} ${AppStrings.calories}',
    subtitle: AppStrings.per100Gram,
    trailingAsset: AppAssets.iconsCalory,
  ),
];
