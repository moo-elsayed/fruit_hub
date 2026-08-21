import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../domain/repo/profile_repo.dart';
import '../data_sources/remote/profile_remote_data_source.dart';

class ProfileRepoImp implements ProfileRepo {
  ProfileRepoImp(this._profileRemoteDataSource);

  final ProfileRemoteDataSource _profileRemoteDataSource;

  @override
  Future<NetworkResponse<void>> addItemToFavorites(String productId) async =>
      await _profileRemoteDataSource.addItemToFavorites(productId);

  @override
  Future<NetworkResponse<void>> removeItemFromFavorites(
    String productId,
  ) async => await _profileRemoteDataSource.removeItemFromFavorites(productId);

  @override
  Future<NetworkResponse<List<String>>> getFavoriteIds() async =>
      _profileRemoteDataSource.getFavoriteIds();

  @override
  Future<NetworkResponse<List<FruitEntity>>> getFavorites(
    List<String> ids,
  ) async {
    final response = await _profileRemoteDataSource.getFavorites(ids);
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
