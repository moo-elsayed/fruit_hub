import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database_service.dart';
import 'package:fruit_hub/features/auth/data/firebase/auth_firebase.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/domain/repo_contract/data_sources/remote/auth_remote_data_source.dart';
import '../../../../../../core/helpers/backend_endpoints.dart';
import '../../../../domain/entities/user_entity.dart';

class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  AuthRemoteDataSourceImp(this._authFirebase, this._databaseService);

  final AuthFirebase _authFirebase;
  final DatabaseService _databaseService;

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
        if (!result.data!.emailVerified) {
          await sendEmailVerification();
          return NetworkFailure(Exception("please_verify_your_email".tr()));
        } else {
          return NetworkSuccess(UserModel.fromFirebaseUser(result.data!));
        }
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
        UserModel user = UserModel.fromFirebaseUser(result.data!);
        user.name = username;
        await sendEmailVerification();
        await _addUserData(user);
        return NetworkSuccess(user);
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
  Future<NetworkResponse<UserEntity>> googleSignIn() async {
    var result = await _authFirebase.googleSignIn();

    switch (result) {
      case NetworkSuccess<UserCredential>():
        return NetworkSuccess(UserModel.fromFirebaseUser(result.data!.user!));
      case NetworkFailure<UserCredential>():
        return NetworkFailure(result.exception);
    }
  }

  @override
  Future<void> forgetPassword(String email) async =>
      await _authFirebase.forgetPassword(email);

  @override
  Future<NetworkResponse<UserEntity>> facebookSignIn() async {
    var result = await _authFirebase.facebookSignIn();

    switch (result) {
      case NetworkSuccess<User>():
        return NetworkSuccess(UserModel.fromFirebaseUser(result.data!));
      case NetworkFailure<User>():
        return NetworkFailure(result.exception);
    }
  }

  Future _addUserData(UserModel user) async => await _databaseService.addData(
    docId: user.uid,
    path: BackendEndpoints.addUserData,
    data: user.toJson(),
  );
}
