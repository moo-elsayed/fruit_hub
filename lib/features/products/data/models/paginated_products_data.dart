import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/features/products/domain/entities/paginated_products_entity.dart';

class PaginatedProductsData {
  const PaginatedProductsData({
    required this.fruits,
    this.lastDoc,
    required this.hasMore,
  });

  final List<FruitModel> fruits;
  final dynamic lastDoc;
  final bool hasMore;

  PaginatedProductsEntity toEntity() => PaginatedProductsEntity(
    fruits: fruits.map((fruit) => fruit.toEntity()).toList(),
    lastDoc: lastDoc,
    hasMore: hasMore,
  );
}
