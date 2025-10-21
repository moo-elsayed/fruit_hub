import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';

abstract class HomeRepo {
  Future<NetworkResponse<List<FruitEntity>>> getBestSellerProducts();
}
