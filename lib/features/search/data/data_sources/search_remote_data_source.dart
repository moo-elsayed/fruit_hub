import 'package:fruit_hub/core/entities/fruit_entity.dart';
import '../../../../core/helpers/network_response.dart';

abstract class SearchRemoteDataSource {
  Future<NetworkResponse<List<FruitEntity>>> searchFruits(String query);
}
