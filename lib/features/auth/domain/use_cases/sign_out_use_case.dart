import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/clear_user_session_use_case.dart';
import '../repo/auth_repo.dart';

class SignOutUseCase {
  SignOutUseCase(this._authRepo, this._clearUserSessionUseCase);

  final AuthRepo _authRepo;
  final ClearUserSessionUseCase _clearUserSessionUseCase;

  Future<NetworkResponse<void>> call() async {
    final networkResponse = await _authRepo.signOut();
    switch (networkResponse) {
      case NetworkSuccess<void>():
        try {
          await _clearUserSessionUseCase.call();
          return const NetworkSuccess();
        } catch (e) {
          return NetworkFailure(
            ServerFailure(error: AppStrings.unexpectedError),
          );
        }
      case NetworkFailure<void>():
        return NetworkFailure(networkResponse.failure);
    }
  }
}
