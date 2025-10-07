import 'package:fruit_hub/features/auth/domain/repo_contract/repo/auth_repo.dart';

class SignOutUseCase {
  SignOutUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<void> call() async => await _authRepo.signOut();
}
