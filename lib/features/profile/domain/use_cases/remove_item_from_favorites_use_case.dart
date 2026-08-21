import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';

class RemoveItemFromFavoritesUseCase {
  RemoveItemFromFavoritesUseCase(this._profileRepo);

  final ProfileRepo _profileRepo;

  Future<NetworkResponse<void>> call(String productId) async =>
      _profileRepo.removeItemFromFavorites(productId);
}
