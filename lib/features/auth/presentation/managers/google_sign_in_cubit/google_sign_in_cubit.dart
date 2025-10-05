import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/use_cases/google_sign_in_use_case.dart';
part 'google_sign_in_state.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit(this._googleSignInUseCase) : super(GoogleSignInInitial());

  final GoogleSignInUseCase _googleSignInUseCase;

  Future<void> googleSignIn() async {
    emit(GoogleLoading());
    var result = await _googleSignInUseCase.call();
    switch (result) {
      case NetworkSuccess<UserEntity>():
        emit(GoogleSuccess());
      case NetworkFailure<UserEntity>():
        emit(GoogleFailure(getErrorMessage(result)));
    }
  }
}
