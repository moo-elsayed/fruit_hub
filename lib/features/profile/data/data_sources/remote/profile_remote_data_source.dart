import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';

import '../../models/update_profile_input_model.dart';

abstract class ProfileRemoteDataSource {
  Future<NetworkResponse<UserModel>> updateProfile(
    UpdateProfileInputModel input,
  );

  Future<NetworkResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
