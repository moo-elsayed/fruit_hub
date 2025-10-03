import 'package:fruit_hub/features/auth/domain/repo_contract/repo/auth_repo.dart';
import '../../../../core/helpers/network_response.dart';
import '../entities/user_entity.dart';

class SignInWithEmailAndPasswordUseCase {
  SignInWithEmailAndPasswordUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call({
    required String email,
    required String password,
  }) async =>
      _authRepo.signInWithEmailAndPassword(email: email, password: password);
}
