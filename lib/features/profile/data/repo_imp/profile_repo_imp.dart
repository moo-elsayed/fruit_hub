import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import '../../../../core/helpers/network_response.dart';

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
  ) async => _profileRemoteDataSource.getFavorites(ids);
}
