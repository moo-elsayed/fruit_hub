import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

import '../entities/update_profile_input_entity.dart';

abstract class ProfileRepo {
  Future<NetworkResponse<UserEntity>> updateProfile(
    UpdateProfileInputEntity input,
  );

  Future<NetworkResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
