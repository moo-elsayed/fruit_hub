import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class HomeRepo {
  Future<NetworkResponse<List<FruitEntity>>> getBestSellerProducts();
}
