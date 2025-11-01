import '../repo/auth_repo.dart';

class SignOutUseCase {
  SignOutUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<void> call() async => await _authRepo.signOut();
}
