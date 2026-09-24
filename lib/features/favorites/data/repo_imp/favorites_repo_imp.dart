import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/data/data_sources/remote/favorites_remote_data_source.dart';
import 'package:fruit_hub/features/favorites/domain/repo/favorites_repo.dart';

class FavoritesRepoImp implements FavoritesRepo {
  FavoritesRepoImp(this._favoritesRemoteDataSource);

  final FavoritesRemoteDataSource _favoritesRemoteDataSource;

  @override
  Future<NetworkResponse<void>> addItemToFavorites(String productId) =>
      _favoritesRemoteDataSource.addItemToFavorites(productId);

  @override
  Future<NetworkResponse<void>> removeItemFromFavorites(String productId) =>
      _favoritesRemoteDataSource.removeItemFromFavorites(productId);

  @override
  Future<NetworkResponse<List<FruitEntity>>> getFavorites() async {
    final response = await _favoritesRemoteDataSource.getFavorites();
    switch (response) {
      case NetworkSuccess<List<FruitModel>>():
        final entities = (response.data ?? [])
            .map((model) => model.toEntity())
            .toList();
        return NetworkSuccess(entities);
      case NetworkFailure<List<FruitModel>>():
        return NetworkFailure(response.failure);
    }
  }
}
