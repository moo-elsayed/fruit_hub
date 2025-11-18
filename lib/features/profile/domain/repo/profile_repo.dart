import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';

abstract class ProfileRepo {
  Future<NetworkResponse<void>> addItemToFavorites(String productId);

  Future<NetworkResponse<void>> removeItemFromFavorites(String productId);

  Future<NetworkResponse<List<String>>> getFavoriteIds();

  Future<NetworkResponse<List<FruitEntity>>> getFavorites(List<String> ids);
}
