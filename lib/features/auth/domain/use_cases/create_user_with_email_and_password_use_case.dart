import '../../../../core/helpers/network_response.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class CreateUserWithEmailAndPasswordUseCase {
  CreateUserWithEmailAndPasswordUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call({
    required String email,
    required String password,
    required String username,
  }) async => await _authRepo.createUserWithEmailAndPassword(
    email: email,
    password: password,
    username: username,
  );
}
