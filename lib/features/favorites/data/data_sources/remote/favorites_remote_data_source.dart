import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<NetworkResponse<void>> addItemToFavorites(String productId);

  Future<NetworkResponse<void>> removeItemFromFavorites(String productId);

  Future<NetworkResponse<List<String>>> getFavoriteIds();

  Future<NetworkResponse<List<FruitModel>>> getFavorites(List<String> ids);
}
