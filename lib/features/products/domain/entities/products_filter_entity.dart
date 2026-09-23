import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';

class ProductsFilterEntity extends Equatable {
  const ProductsFilterEntity({
    this.sortType = ProductSortType.none,
    this.categoryFilter = ProductCategoryFilter.all,
  });

  final ProductSortType sortType;
  final ProductCategoryFilter categoryFilter;

  bool get hasActiveFilters =>
      sortType != ProductSortType.none ||
      categoryFilter != ProductCategoryFilter.all;

  bool get hasActiveSort => sortType != ProductSortType.none;

  ProductsFilterEntity copyWith({
    ProductSortType? sortType,
    ProductCategoryFilter? categoryFilter,
  }) => ProductsFilterEntity(
    sortType: sortType ?? this.sortType,
    categoryFilter: categoryFilter ?? this.categoryFilter,
  );

  @override
  List<Object?> get props => [sortType, categoryFilter];
}
