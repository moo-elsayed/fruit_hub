import 'package:fruit_hub/core/helpers/network_response.dart';

abstract class ProfileRepo {
  Future<NetworkResponse<void>> addItemToFavorites(String productId);

  Future<NetworkResponse<void>> removeItemFromFavorites(String productId);
}
