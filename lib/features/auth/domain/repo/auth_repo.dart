import 'package:fruit_hub/core/network/network_response.dart';
import '../entities/sign_up_input_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<NetworkResponse<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<NetworkResponse<UserEntity>> createUserWithEmailAndPassword(
    SignUpInputEntity input,
  );

  Future<NetworkResponse<UserEntity>> googleSignIn();

  Future<NetworkResponse<UserEntity>> facebookSignIn();

  Future<NetworkResponse<UserEntity>> getUserInfo(String uid);

  Future<NetworkResponse<void>> forgetPassword(String email);

  Future<NetworkResponse<void>> signOut();
}
