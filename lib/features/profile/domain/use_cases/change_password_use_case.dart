import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/profile_repo.dart';

class ChangePasswordUseCase {
  ChangePasswordUseCase(this._profileRepo);

  final ProfileRepo _profileRepo;

  Future<NetworkResponse<void>> call({
    required String currentPassword,
    required String newPassword,
  }) async => await _profileRepo.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
}
