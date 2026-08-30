import 'package:fruit_hub/core/helpers/app_strings.dart';

enum ProductSortType {
  none,
  priceLowestToHighest,
  priceHighestToLowest,
  topRated,
  mostPopular,
  alphabetical;

  String get title => switch (this) {
    ProductSortType.none => '',
    ProductSortType.priceLowestToHighest => AppStrings.priceLowestToHighest,
    ProductSortType.priceHighestToLowest => AppStrings.priceHighestToLowest,
    ProductSortType.topRated => AppStrings.topRated,
    ProductSortType.mostPopular => AppStrings.mostPopular,
    ProductSortType.alphabetical => AppStrings.alphabetical,
  };

  String? get firestoreField => switch (this) {
    ProductSortType.priceLowestToHighest ||
    ProductSortType.priceHighestToLowest => 'price',
    ProductSortType.topRated => 'avgRating',
    ProductSortType.mostPopular => 'sellingCount',
    ProductSortType.alphabetical => 'name',
    ProductSortType.none => null,
  };

  bool get isDescending => switch (this) {
    ProductSortType.priceHighestToLowest ||
    ProductSortType.topRated ||
    ProductSortType.mostPopular => true,
    _ => false,
  };
}
