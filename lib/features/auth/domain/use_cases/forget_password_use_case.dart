import 'package:fruit_hub/features/auth/domain/repo_contract/repo/auth_repo.dart';

class ForgetPasswordUseCase {
  ForgetPasswordUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<void> forgetPassword(String email) async =>
      await _authRepo.forgetPassword(email);
}
