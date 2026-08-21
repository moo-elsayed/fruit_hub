import 'package:fruit_hub/core/network/network_response.dart';
import '../../../../core/entities/fruit_entity.dart';

abstract class ProductsRepo {
  Future<NetworkResponse<List<FruitEntity>>> getAllProducts();
  Future<NetworkResponse<FruitEntity>> getProductDetails(String code);
}
