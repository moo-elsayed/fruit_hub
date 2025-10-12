import 'package:fruit_hub/features/auth/domain/repo_contract/repo/auth_repo.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/helpers/network_response.dart';
import '../entities/user_entity.dart';

class GoogleSignInUseCase {
  GoogleSignInUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call() async {
    var networkResponse = await _authRepo.googleSignIn();
    switch (networkResponse) {
      case NetworkSuccess<UserEntity>():
        await saveUserDataToSharedPreferences(networkResponse.data!);
        return NetworkSuccess(networkResponse.data);
      case NetworkFailure<UserEntity>():
        return NetworkFailure(networkResponse.exception);
    }
  }
}
