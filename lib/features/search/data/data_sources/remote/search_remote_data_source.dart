import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class SearchRemoteDataSource {
  Future<NetworkResponse<List<FruitModel>>> searchFruits(String query);
}
