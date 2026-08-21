import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

abstract class HomeRemoteDataSource {
  Future<NetworkResponse<List<FruitModel>>> getBestSellerProducts();
}
