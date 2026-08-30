import 'package:fruit_hub/shared_data/models/fruit_model.dart';

class PaginatedProductsData {
  const PaginatedProductsData({
    required this.fruits,
    this.lastDoc,
    required this.hasMore,
  });

  final List<FruitModel> fruits;
  final dynamic lastDoc;
  final bool hasMore;
}
