import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

import '../../domain/entities/update_profile_input_entity.dart';
import '../../domain/repo/profile_repo.dart';
import '../data_sources/remote/profile_remote_data_source.dart';
import '../models/update_profile_input_model.dart';

class ProfileRepoImp implements ProfileRepo {
  ProfileRepoImp(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<NetworkResponse<UserEntity>> updateProfile(
    UpdateProfileInputEntity input,
  ) async {
    final response = await _remoteDataSource.updateProfile(
      UpdateProfileInputModel.fromEntity(input),
    );

    return switch (response) {
      NetworkSuccess<UserModel>() => NetworkSuccess(
        response.data?.toUserEntity() ?? const UserEntity(),
      ),
      NetworkFailure<UserModel>() => NetworkFailure(response.failure),
    };
  }

  @override
  Future<NetworkResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => await _remoteDataSource.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
}
