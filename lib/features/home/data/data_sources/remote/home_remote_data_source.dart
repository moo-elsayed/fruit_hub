import '../../../../../core/entities/fruit_entity.dart';
import '../../../../../core/helpers/network_response.dart';

abstract class HomeRemoteDataSource {
  Future<NetworkResponse<List<FruitEntity>>> getAllProducts();

  Future<NetworkResponse<List<FruitEntity>>> getBestSellerProducts();
}
