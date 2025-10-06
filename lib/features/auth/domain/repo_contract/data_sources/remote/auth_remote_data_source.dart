import '../../../../../../core/helpers/network_response.dart';
import '../../../entities/user_entity.dart';

abstract class AuthRemoteDataSource {
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

  Future<NetworkResponse<UserEntity>> googleSignIn();

  Future<NetworkResponse<UserEntity>> facebookSignIn();

  Future<void> forgetPassword(String email);

  Future<void> signOut();
}
