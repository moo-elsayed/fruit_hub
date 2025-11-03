import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../core/helpers/backend_endpoints.dart';
import '../../../../../../core/helpers/failures.dart';
import '../../../../../../core/helpers/functions.dart';
import '../../../../../../core/helpers/network_response.dart';
import '../../../../../../core/services/authentication/auth_service.dart';
import '../../../../../../core/services/database/database_service.dart';
import '../../../domain/entities/user_entity.dart';
import 'auth_remote_data_source.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  final AuthService _authService;
  final DatabaseService _databaseService;

  AuthRemoteDataSourceImp(this._authService, this._databaseService);

  @override
  Future<NetworkResponse<UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userEntity = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel.fromUserEntity(userEntity)..name = username;
      await _addUserData(userModel);

      await _authService.sendEmailVerification();

      return NetworkSuccess(userModel.toUserEntity());
    } on FirebaseAuthException catch (e) {
      if (e.code != "email-already-in-use") {
        await _authService.deleteCurrentUser();
      }
      return _handleAuthError(e, "createUserWithEmailAndPassword");
    } catch (e) {
      await _authService.deleteCurrentUser();
      return _handleAuthError(e, "createUserWithEmailAndPassword");
    }
  }

  @override
  Future<NetworkResponse<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userEntity = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userEntity.isVerified) {
        await _authService.sendEmailVerification();
        return NetworkFailure(Exception("please_verify_your_email"));
      }

      final updatedUser = await _getOrUpdateUserFromDB(userEntity);
      return NetworkSuccess(updatedUser);
    } catch (e) {
      return _handleAuthError(e, "signInWithEmailAndPassword");
    }
  }

  @override
  Future<NetworkResponse<UserEntity>> googleSignIn() async {
    try {
      final userEntity = await _authService.googleSignIn();
      final updatedUser = await _getOrUpdateUserFromDB(userEntity);
      return NetworkSuccess(updatedUser);
    } catch (e) {
      return _handleAuthError(e, "googleSignIn");
    }
  }

  @override
  Future<NetworkResponse<void>> forgetPassword(String email) async {
    try {
      var bool = await _checkIfEmailExists(email);
      if (bool) {
        await _authService.forgetPassword(email);
        return const NetworkSuccess();
      } else {
        return NetworkFailure(Exception("no_user_found_for_that_email"));
      }
    } catch (e) {
      return _handleAuthError(e, "forgetPassword");
    }
  }

  @override
  Future<NetworkResponse<void>> signOut() async {
    try {
      await _authService.signOut();
      return const NetworkSuccess();
    } catch (e) {
      return _handleAuthError(e, "signOut");
    }
  }

  @override
  Future<NetworkResponse<UserEntity>> facebookSignIn() async {
    try {
      final userEntity = await _authService.facebookSignIn();

      final updatedUser = await _getOrUpdateUserFromDB(userEntity);

      return NetworkSuccess(updatedUser);
    } catch (e) {
      return _handleAuthError(e, "facebookSignIn");
    }
  }

  // -------------------------------------------------------------------
  // Private Helper Methods
  // -------------------------------------------------------------------

  NetworkFailure<T> _handleAuthError<T>(Object e, String functionName) {
    errorLogger(
      functionName: 'AuthRemoteDataSourceImp.$functionName',
      error: e.toString(),
    );
    if (e is FirebaseAuthException) {
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    }
    return NetworkFailure(Exception("error_occurred_please_try_again"));
  }

  Future<UserEntity> _getOrUpdateUserFromDB(UserEntity user) async {
    final userExists = await _checkIfUserExists(user.uid);
    final userModel = UserModel.fromUserEntity(user);

    if (userExists) {
      await _updateUserData(userModel);
    } else {
      await _addUserData(userModel);
    }
    return userModel.toUserEntity();
  }

  Future<void> _addUserData(UserModel user) async =>
      await _databaseService.addData(
        docId: user.uid,
        path: BackendEndpoints.addUserData,
        data: user.toJson(),
      );

  Future<void> _updateUserData(UserModel user) async =>
      await _databaseService.updateData(
        path: BackendEndpoints.updateUserData,
        documentId: user.uid,
        data: {'isVerified': user.isVerified},
      );

  Future<bool> _checkIfUserExists(String uid) async =>
      await _databaseService.checkIfDataExists(
        path: BackendEndpoints.checkIfUserExists,
        documentId: uid,
      );

  Future<bool> _checkIfEmailExists(String email) async =>
      await _databaseService.checkIfFieldExists(
        path: BackendEndpoints.checkIfEmailExists,
        fieldName: 'email',
        fieldValue: email,
      );
}
