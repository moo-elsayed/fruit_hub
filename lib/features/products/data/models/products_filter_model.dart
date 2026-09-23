import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';

class ProductsFilterModel {
  const ProductsFilterModel({
    this.sortType = ProductSortType.none,
    this.categoryFilter = ProductCategoryFilter.all,
  });

  factory ProductsFilterModel.fromEntity(ProductsFilterEntity entity) =>
      ProductsFilterModel(
        sortType: entity.sortType,
        categoryFilter: entity.categoryFilter,
      );

  final ProductSortType sortType;
  final ProductCategoryFilter categoryFilter;

  ProductsFilterEntity toEntity() =>
      ProductsFilterEntity(sortType: sortType, categoryFilter: categoryFilter);
}
