import 'package:fruit_hub/core/network/network_response.dart';

import '../../models/sign_up_input_model.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<NetworkResponse<UserModel>> createUserWithEmailAndPassword(
    SignUpInputModel input,
  );

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
