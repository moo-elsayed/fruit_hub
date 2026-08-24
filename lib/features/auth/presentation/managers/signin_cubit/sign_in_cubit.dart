import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._signInWithEmailAndPasswordUseCase) : super(SignInInitial());

  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPasswordUseCase;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(SignInLoading());
    final result = await _signInWithEmailAndPasswordUseCase.call(
      email: email,
      password: password,
    );
    switch (result) {
      case NetworkSuccess<UserEntity>():
        if (result.data != null) {
          await getIt<UserInfoCubit>().saveUserLocally(result.data!);
        }
        emit(SignInSuccess());
      case NetworkFailure<UserEntity>():
        emit(SignInFailure(result.error));
    }
  }
}
