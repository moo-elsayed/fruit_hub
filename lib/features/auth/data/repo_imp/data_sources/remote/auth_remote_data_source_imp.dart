import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/data/firebase/auth_firebase.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/domain/repo_contract/data_sources/remote/auth_remote_data_source.dart';
import '../../../../domain/entities/user_entity.dart';

class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  AuthRemoteDataSourceImp(this._authFirebase);

  final AuthFirebase _authFirebase;

  @override
  Future<NetworkResponse<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    var result = await _authFirebase.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    switch (result) {
      case NetworkSuccess<User>():
        return NetworkSuccess(UserModel.fromFirebaseUser(result.data!));
      case NetworkFailure<User>():
        return NetworkFailure(result.exception);
    }
  }

  @override
  Future<NetworkResponse<UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    var result = await _authFirebase.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    switch (result) {
      case NetworkSuccess<User>():
        return NetworkSuccess(UserModel.fromFirebaseUser(result.data!));
      case NetworkFailure<User>():
        return NetworkFailure(result.exception);
    }
  }

  @override
  Future<void> signOut() async => await _authFirebase.signOut();

  @override
  Future<void> sendEmailVerification() async =>
      await _authFirebase.sendEmailVerification();

  @override
  Future<NetworkResponse> forgetPassword(String email) {
    // TODO: implement forgetPassword
    throw UnimplementedError();
  }

  @override
  Future<NetworkResponse> googleSignIn() {
    // TODO: implement googleSignIn
    throw UnimplementedError();
  }
}
