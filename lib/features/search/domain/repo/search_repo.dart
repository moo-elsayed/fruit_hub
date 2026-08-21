import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class SearchRepo {
  Future<NetworkResponse<List<FruitEntity>>> searchFruits(String query);
}
