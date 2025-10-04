import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

import '../../../../../core/helpers/network_response.dart';

abstract class AuthRepo {
  Future<NetworkResponse<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<NetworkResponse<UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  });

  Future<void> sendEmailVerification();

  Future<NetworkResponse> googleSignIn();

  Future<NetworkResponse> forgetPassword(String email);

  Future<void> signOut();
}
