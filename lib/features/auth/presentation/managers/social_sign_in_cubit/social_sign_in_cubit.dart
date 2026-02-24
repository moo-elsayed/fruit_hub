import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/use_cases/facebook_sign_in_use_case.dart';
import '../../../domain/use_cases/google_sign_in_use_case.dart';

part 'social_sign_in_state.dart';

class SocialSignInCubit extends Cubit<SocialSignInState> {
  SocialSignInCubit(this._googleSignInUseCase, this._facebookSignInUseCase)
    : super(SocialSignInInitial());

  final GoogleSignInUseCase _googleSignInUseCase;
  final FacebookSignInUseCase _facebookSignInUseCase;

  Future<void> googleSignIn() async {
    emit(GoogleLoading());
    var result = await _googleSignInUseCase.call();
    switch (result) {
      case NetworkSuccess<UserEntity>():
        emit(GoogleSuccess());
      case NetworkFailure<UserEntity>():
        emit(GoogleFailure(getErrorMessage(result).tr()));
    }
  }

  Future<void> facebookSignIn() async {
    emit(FacebookLoading());
    var result = await _facebookSignInUseCase.call();

    switch (result) {
      case NetworkSuccess<UserEntity>():
        emit(FacebookSuccess());
      case NetworkFailure<UserEntity>():
        emit(FacebookFailure(getErrorMessage(result).tr()));
    }
  }
}
