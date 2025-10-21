import '../../../../core/entities/fruit_entity.dart';
import '../../../../core/helpers/network_response.dart';

abstract class ProductsRepo{
  Future<NetworkResponse<List<FruitEntity>>> getAllProducts();
}