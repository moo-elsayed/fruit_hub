import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/favorites_repo.dart';

class GetFavoriteIdsUseCase {
  GetFavoriteIdsUseCase(this._favoritesRepo);

  final FavoritesRepo _favoritesRepo;

  Future<NetworkResponse<List<String>>> call() async =>
      await _favoritesRepo.getFavoriteIds();
}
