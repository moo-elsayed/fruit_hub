import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../domain/repo/favorites_repo.dart';
import '../data_sources/remote/favorites_remote_data_source.dart';

class FavoritesRepoImp implements FavoritesRepo {
  FavoritesRepoImp(this._favoritesRemoteDataSource);

  final FavoritesRemoteDataSource _favoritesRemoteDataSource;

  @override
  Future<NetworkResponse<void>> addItemToFavorites(String productId) async =>
      await _favoritesRemoteDataSource.addItemToFavorites(productId);

  @override
  Future<NetworkResponse<void>> removeItemFromFavorites(
    String productId,
  ) async =>
      await _favoritesRemoteDataSource.removeItemFromFavorites(productId);

  @override
  Future<NetworkResponse<List<String>>> getFavoriteIds() async =>
      _favoritesRemoteDataSource.getFavoriteIds();

  @override
  Future<NetworkResponse<List<FruitEntity>>> getFavorites(
    List<String> ids,
  ) async {
    final response = await _favoritesRemoteDataSource.getFavorites(ids);
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
