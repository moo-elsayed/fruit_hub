import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import '../entities/paginated_products_entity.dart';
import '../entities/products_filter_entity.dart';

abstract class ProductsRepo {
  Future<NetworkResponse<PaginatedProductsEntity>> getProducts({
    dynamic lastDoc,
    int limit = 10,
    ProductsFilterEntity? filter,
  });
  Future<NetworkResponse<FruitEntity>> getProductDetails(String code);
}
