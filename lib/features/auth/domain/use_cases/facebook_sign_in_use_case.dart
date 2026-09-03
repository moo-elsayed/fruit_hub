import 'package:fruit_hub/core/network/network_response.dart';

import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class FacebookSignInUseCase {
  FacebookSignInUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call() async =>
      await _authRepo.facebookSignIn();
}
