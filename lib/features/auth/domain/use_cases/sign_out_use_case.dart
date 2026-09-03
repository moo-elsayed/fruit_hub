import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/auth_repo.dart';

class SignOutUseCase {
  SignOutUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<void>> call() async => await _authRepo.signOut();
}
