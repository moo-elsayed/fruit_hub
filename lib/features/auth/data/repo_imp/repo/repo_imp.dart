import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import '../../../domain/repo_contract/data_sources/remote/auth_remote_data_source.dart';
import '../../../domain/repo_contract/repo/auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  AuthRepoImp(this._authRemoteDataSource);

  final AuthRemoteDataSource _authRemoteDataSource;

  @override
  Future<NetworkResponse<UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async => _authRemoteDataSource.createUserWithEmailAndPassword(
    email: email,
    password: password,
    username: username,
  );

  @override
  Future<NetworkResponse<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => _authRemoteDataSource.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  @override
  Future<void> signOut() async => _authRemoteDataSource.signOut();

  @override
  Future<void> sendEmailVerification() async =>
      _authRemoteDataSource.sendEmailVerification();

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
