import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

import '../entities/update_profile_input_entity.dart';
import '../repo/profile_repo.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._profileRepo);

  final ProfileRepo _profileRepo;

  Future<NetworkResponse<UserEntity>> call(
    UpdateProfileInputEntity input,
  ) async => await _profileRepo.updateProfile(input);
}
