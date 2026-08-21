import 'package:fruit_hub/core/network/network_response.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<NetworkResponse<UserModel>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  });

  Future<NetworkResponse<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<NetworkResponse<UserModel>> googleSignIn();

  Future<NetworkResponse<UserModel>> facebookSignIn();

  Future<NetworkResponse<UserModel>> getUserInfo(String uid);

  Future<NetworkResponse<void>> forgetPassword(String email);

  Future<NetworkResponse<void>> signOut();
}
