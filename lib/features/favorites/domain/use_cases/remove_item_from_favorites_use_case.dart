import 'package:fruit_hub/core/network/network_response.dart';
import '../repo/favorites_repo.dart';

class RemoveItemFromFavoritesUseCase {
  RemoveItemFromFavoritesUseCase(this._favoritesRepo);

  final FavoritesRepo _favoritesRepo;

  Future<NetworkResponse<void>> call(String productId) async =>
      await _favoritesRepo.removeItemFromFavorites(productId);
}
