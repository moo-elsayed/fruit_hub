import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import '../../../../core/helpers/network_response.dart';

class GetFavoritesUseCase {
  GetFavoritesUseCase(this._profileRepo);

  final ProfileRepo _profileRepo;

  Future<NetworkResponse<List<FruitEntity>>> call(List<String> ids) async =>
      await _profileRepo.getFavorites(ids);
}
