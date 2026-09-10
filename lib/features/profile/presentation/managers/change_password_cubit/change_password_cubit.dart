import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../../domain/use_cases/change_password_use_case.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePasswordUseCase)
    : super(const ChangePasswordInitial());

  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordLoading());

    final response = await _changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    switch (response) {
      case NetworkSuccess<void>():
        emit(const ChangePasswordSuccess());
      case NetworkFailure<void>():
        emit(ChangePasswordFailure(response.error));
    }
  }
}
