import 'package:fruit_hub/core/network/network_response.dart';

import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class SignInWithEmailAndPasswordUseCase {
  SignInWithEmailAndPasswordUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call({
    required String email,
    required String password,
  }) async => await _authRepo.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
