import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/data/models/paginated_products_data.dart';
import 'package:fruit_hub/features/products/data/models/products_filter_model.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

abstract class ProductsRemoteDataSource {
  Future<NetworkResponse<PaginatedProductsData>> getProducts({
    dynamic lastDoc,
    int limit = 10,
    ProductsFilterModel? filter,
  });
  Future<NetworkResponse<FruitModel>> getProductDetails(String code);
}
