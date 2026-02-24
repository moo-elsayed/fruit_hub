import '../../../../core/helpers/network_response.dart';
import '../repo/auth_repo.dart';

class ForgetPasswordUseCase {
  ForgetPasswordUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<void>> call(String email) async =>
      await _authRepo.forgetPassword(email);
}
