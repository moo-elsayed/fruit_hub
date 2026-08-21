import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

abstract class SearchRemoteDataSource {
  Future<NetworkResponse<List<FruitModel>>> searchFruits(String query);
}
