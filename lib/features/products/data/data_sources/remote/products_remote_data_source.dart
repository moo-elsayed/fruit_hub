import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

abstract class ProductsRemoteDataSource {
  Future<NetworkResponse<List<FruitModel>>> getAllProducts();
  Future<NetworkResponse<FruitModel>> getProductDetails(String code);
}
