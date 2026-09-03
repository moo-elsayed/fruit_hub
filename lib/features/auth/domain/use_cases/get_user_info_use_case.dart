import 'package:fruit_hub/core/network/network_response.dart';

import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class GetUserInfoUseCase {
  GetUserInfoUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call(String uid) async =>
      await _authRepo.getUserInfo(uid);
}
