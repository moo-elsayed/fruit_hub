import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import '../../../../core/helpers/network_response.dart';

class GetFavoriteIdsUseCase {
  GetFavoriteIdsUseCase(this._profileRepo);

  final ProfileRepo _profileRepo;

  Future<NetworkResponse<List<String>>> call() async =>
      await _profileRepo.getFavoriteIds();
}
