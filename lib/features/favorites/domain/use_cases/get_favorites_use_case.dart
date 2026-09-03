import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/favorites_repo.dart';

class GetFavoritesUseCase {
  GetFavoritesUseCase(this._favoritesRepo);

  final FavoritesRepo _favoritesRepo;

  Future<NetworkResponse<List<FruitEntity>>> call(List<String> ids) async =>
      await _favoritesRepo.getFavorites(ids);
}
