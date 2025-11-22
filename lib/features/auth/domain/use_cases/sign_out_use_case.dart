import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/clear_user_session_use_case.dart';
import '../repo/auth_repo.dart';

class SignOutUseCase {
  SignOutUseCase(this._authRepo, this._clearUserSessionUseCase);

  final AuthRepo _authRepo;
  final ClearUserSessionUseCase _clearUserSessionUseCase;

  Future<NetworkResponse<void>> call() async {
    var networkResponse = await _authRepo.signOut();
    switch (networkResponse) {
      case NetworkSuccess<void>():
        try {
          await _clearUserSessionUseCase.call();
          return const NetworkSuccess();
        } catch (e) {
          return NetworkFailure(Exception("error_occurred_please_try_again"));
        }
      case NetworkFailure<void>():
        return NetworkFailure(networkResponse.exception);
    }
  }
}
