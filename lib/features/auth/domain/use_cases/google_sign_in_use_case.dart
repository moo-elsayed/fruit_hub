import 'package:fruit_hub/features/auth/domain/repo_contract/repo/auth_repo.dart';
import '../../../../core/helpers/network_response.dart';
import '../entities/user_entity.dart';

class GoogleSignInUseCase {
  GoogleSignInUseCase(this._authRepo);

  final AuthRepo _authRepo;

  Future<NetworkResponse<UserEntity>> call() async =>
      await _authRepo.googleSignIn();
}
