import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';

import '../../../domain/entities/update_profile_input_entity.dart';
import '../../../domain/use_cases/update_profile_use_case.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._updateProfileUseCase, this._userInfoCubit)
    : super(const EditProfileInitial());

  final UpdateProfileUseCase _updateProfileUseCase;
  final UserInfoCubit _userInfoCubit;

  UserEntity? get currentUser => _userInfoCubit.currentUser;

  Future<void> updateProfile(UpdateProfileInputEntity input) async {
    if (input.uid.isEmpty) {
      emit(EditProfileFailure(AppStrings.userNotFound));
      return;
    }

    emit(const EditProfileLoading());

    final response = await _updateProfileUseCase(input);

    switch (response) {
      case NetworkSuccess<UserEntity>():
        if (response.data != null) {
          await _userInfoCubit.saveUserLocally(response.data!);
          emit(EditProfileSuccess(response.data!));
        } else {
          emit(EditProfileFailure(AppStrings.unexpectedError));
        }
      case NetworkFailure<UserEntity>():
        emit(EditProfileFailure(response.error));
    }
  }
}
