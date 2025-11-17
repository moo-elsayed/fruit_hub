import '../../../../../core/helpers/network_response.dart';

abstract class ProfileRemoteDataSource {
  Future<NetworkResponse<void>> addItemToFavorites(String productId);

  Future<NetworkResponse<void>> removeItemFromFavorites(String productId);
}
