import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';

class GetFavoriteIdsUseCase {
  GetFavoriteIdsUseCase(this._profileRepo);

  final ProfileRepo _profileRepo;

  Future<NetworkResponse<List<String>>> call() async =>
      await _profileRepo.getFavoriteIds();
}
