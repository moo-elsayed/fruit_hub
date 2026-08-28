import 'package:fruit_hub/core/network/network_response.dart';
import '../repo/favorites_repo.dart';

class AddItemToFavoritesUseCase {
  AddItemToFavoritesUseCase(this._favoritesRepo);

  final FavoritesRepo _favoritesRepo;

  Future<NetworkResponse<void>> call(String productId) async =>
      await _favoritesRepo.addItemToFavorites(productId);
}
