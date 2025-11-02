import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../domain/entities/user_entity.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._signInWithEmailAndPasswordUseCase) : super(SignInInitial());

  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPasswordUseCase;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(SignInLoading());
    var result = await _signInWithEmailAndPasswordUseCase.call(
      email: email,
      password: password,
    );
    switch (result) {
      case NetworkSuccess<UserEntity>():
        emit(SignInSuccess(result.data!));
      case NetworkFailure<UserEntity>():
        emit(SignInFailure(getErrorMessage(result).tr()));
    }
  }
}
