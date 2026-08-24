import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';

part 'social_sign_in_state.dart';

class SocialSignInCubit extends Cubit<SocialSignInState> {
  SocialSignInCubit(this._googleSignInUseCase, this._facebookSignInUseCase)
    : super(SocialSignInInitial());

  final GoogleSignInUseCase _googleSignInUseCase;
  final FacebookSignInUseCase _facebookSignInUseCase;

  Future<void> googleSignIn() async {
    emit(GoogleLoading());
    final result = await _googleSignInUseCase.call();
    switch (result) {
      case NetworkSuccess<UserEntity>():
        if (result.data != null) {
          await getIt<UserInfoCubit>().saveUserLocally(result.data!);
        }
        emit(GoogleSuccess());
      case NetworkFailure<UserEntity>():
        emit(GoogleFailure(result.error));
    }
  }

  Future<void> facebookSignIn() async {
    emit(FacebookLoading());
    final result = await _facebookSignInUseCase.call();

    switch (result) {
      case NetworkSuccess<UserEntity>():
        if (result.data != null) {
          await getIt<UserInfoCubit>().saveUserLocally(result.data!);
        }
        emit(FacebookSuccess());
      case NetworkFailure<UserEntity>():
        emit(FacebookFailure(result.error));
    }
  }
}
