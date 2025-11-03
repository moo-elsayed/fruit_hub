import 'package:fruit_hub/features/auth/domain/use_cases/save_user_session_use_case.dart';
import '../../../../core/helpers/network_response.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class SignInWithEmailAndPasswordUseCase {
  SignInWithEmailAndPasswordUseCase(
    this._authRepo,
    this._saveUserSessionUseCase,
  );

  final AuthRepo _authRepo;
  final SaveUserSessionUseCase _saveUserSessionUseCase;

  Future<NetworkResponse<UserEntity>> call({
    required String email,
    required String password,
  }) async {
    var networkResponse = await _authRepo.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    switch (networkResponse) {
      case NetworkSuccess<UserEntity>():
        try {
          await _saveUserSessionUseCase.call(networkResponse.data!);
          return NetworkSuccess(networkResponse.data);
        } catch (e) {
          return NetworkFailure(Exception("error_occurred_please_try_again"));
        }
      case NetworkFailure<UserEntity>():
        return NetworkFailure(networkResponse.exception);
    }
  }
}
