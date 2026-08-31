import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class FavoritesRemoteDataSource {
  Future<NetworkResponse<void>> addItemToFavorites(String productId);

  Future<NetworkResponse<void>> removeItemFromFavorites(String productId);

  Future<NetworkResponse<List<String>>> getFavoriteIds();

  Future<NetworkResponse<List<FruitModel>>> getFavorites(List<String> ids);
}
