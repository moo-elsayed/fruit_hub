import '../../../../../core/entities/fruit_entity.dart';
import '../../../../../core/helpers/network_response.dart';

abstract class ProfileRemoteDataSource {
  Future<NetworkResponse<void>> addItemToFavorites(String productId);

  Future<NetworkResponse<void>> removeItemFromFavorites(String productId);

  Future<NetworkResponse<List<String>>> getFavoriteIds();

  Future<NetworkResponse<List<FruitEntity>>> getFavorites(List<String> ids);
}
