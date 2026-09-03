import 'package:fruit_hub/core/network/network_response.dart';

import '../entities/sign_up_input_entity.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class CreateUserWithEmailAndPasswordUseCase {
  CreateUserWithEmailAndPasswordUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call(SignUpInputEntity input) async =>
      await _authRepo.createUserWithEmailAndPassword(input);
}
