import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import '../../../../core/helpers/network_response.dart';

class AddItemToFavoritesUseCase {
  AddItemToFavoritesUseCase(this._profileRepo);

  final ProfileRepo _profileRepo;

  Future<NetworkResponse<void>> call(String productId) async =>
      _profileRepo.addItemToFavorites(productId);
}
