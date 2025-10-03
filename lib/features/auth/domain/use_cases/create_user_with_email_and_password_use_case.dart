import 'package:fruit_hub/features/auth/domain/repo_contract/repo/auth_repo.dart';
import '../../../../core/helpers/network_response.dart';
import '../entities/user_entity.dart';

class CreateUserWithEmailAndPasswordUseCase {
  CreateUserWithEmailAndPasswordUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call({
    required String email,
    required String password,
    required String username,
  }) async {
    var result = await _authRepo.createUserWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
    );

    switch (result) {
      case NetworkSuccess<UserEntity>():
        await _authRepo.sendEmailVerification();
        return NetworkSuccess(result.data!);
      case NetworkFailure<UserEntity>():
        return NetworkFailure(result.exception);
    }
  }
}
