import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class HomeRemoteDataSource {
  Future<NetworkResponse<List<FruitModel>>> getBestSellerProducts();
}
