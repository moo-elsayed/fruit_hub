import 'package:fruit_hub/core/helpers/app_strings.dart';

enum ProductCategoryFilter {
  all,
  organic,
  featured;

  String get label => switch (this) {
    ProductCategoryFilter.all => AppStrings.all,
    ProductCategoryFilter.organic => AppStrings.organic,
    ProductCategoryFilter.featured => AppStrings.featured,
  };

  String? get firestoreField => switch (this) {
    ProductCategoryFilter.organic => 'isOrganic',
    ProductCategoryFilter.featured => 'isFeatured',
    ProductCategoryFilter.all => null,
  };
}
