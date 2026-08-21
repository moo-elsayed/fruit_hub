import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_sources/remote/auth_remote_data_source.dart';

class AuthRepoImp implements AuthRepo {
  AuthRepoImp(this._authRemoteDataSource);

  final AuthRemoteDataSource _authRemoteDataSource;

  @override
  Future<NetworkResponse<UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _authRemoteDataSource.createUserWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
    );
    return _mapToEntityResponse(response);
  }

  @override
  Future<NetworkResponse<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _authRemoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapToEntityResponse(response);
  }

  @override
  Future<NetworkResponse<UserEntity>> googleSignIn() async {
    final response = await _authRemoteDataSource.googleSignIn();
    return _mapToEntityResponse(response);
  }

  @override
  Future<NetworkResponse<UserEntity>> facebookSignIn() async {
    final response = await _authRemoteDataSource.facebookSignIn();
    return _mapToEntityResponse(response);
  }

  @override
  Future<NetworkResponse<UserEntity>> getUserInfo(String uid) async {
    final response = await _authRemoteDataSource.getUserInfo(uid);
    return _mapToEntityResponse(response);
  }

  @override
  Future<NetworkResponse<void>> signOut() async =>
      await _authRemoteDataSource.signOut();

  @override
  Future<NetworkResponse<void>> forgetPassword(String email) async =>
      await _authRemoteDataSource.forgetPassword(email);

  /// helper method
  NetworkResponse<UserEntity> _mapToEntityResponse(
    NetworkResponse<UserModel> response,
  ) {
    switch (response) {
      case NetworkSuccess<UserModel>():
        return NetworkSuccess(response.data?.toUserEntity());
      case NetworkFailure<UserModel>():
        return NetworkFailure(response.failure);
    }
  }
}
