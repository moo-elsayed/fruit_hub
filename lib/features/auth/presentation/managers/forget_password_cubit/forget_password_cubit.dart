import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/forget_password_use_case.dart';
part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit(this._forgetPasswordUseCase)
    : super(ForgetPasswordInitial());

  final ForgetPasswordUseCase _forgetPasswordUseCase;

  Future<void> forgetPassword(String email) async {
    emit(ForgetPasswordLoading());
    await _forgetPasswordUseCase.forgetPassword(email);
    emit(ForgetPasswordSuccess());
  }
}
