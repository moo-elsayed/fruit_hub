import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';

class ProductsFilterEntity extends Equatable {
  const ProductsFilterEntity({
    this.sortType = ProductSortType.none,
    this.categoryFilter = ProductCategoryFilter.all,
    this.minPrice,
    this.maxPrice,
  });

  final ProductSortType sortType;
  final ProductCategoryFilter categoryFilter;
  final double? minPrice;
  final double? maxPrice;

  bool get hasActiveFilters =>
      sortType != ProductSortType.none ||
      categoryFilter != ProductCategoryFilter.all ||
      minPrice != null ||
      maxPrice != null;

  bool get hasActiveSort => sortType != ProductSortType.none;

  ProductsFilterEntity copyWith({
    ProductSortType? sortType,
    ProductCategoryFilter? categoryFilter,
    double? minPrice,
    double? maxPrice,
    bool clearPrice = false,
  }) => ProductsFilterEntity(
    sortType: sortType ?? this.sortType,
    categoryFilter: categoryFilter ?? this.categoryFilter,
    minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
    maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
  );

  @override
  List<Object?> get props => [sortType, categoryFilter, minPrice, maxPrice];
}
