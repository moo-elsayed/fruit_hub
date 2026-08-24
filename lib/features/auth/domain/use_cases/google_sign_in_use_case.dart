import 'package:fruit_hub/core/network/network_response.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

class GoogleSignInUseCase {
  GoogleSignInUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call() async =>
      await _authRepo.googleSignIn();
}
