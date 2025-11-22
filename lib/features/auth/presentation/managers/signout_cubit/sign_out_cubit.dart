import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/services/authentication/auth_service.dart';
import '../../../../../core/helpers/functions.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../domain/use_cases/sign_out_use_case.dart';

part 'sign_out_state.dart';

class SignOutCubit extends Cubit<SignOutState> implements SignOutService {
  SignOutCubit(this._signOutUseCase) : super(SignOutInitial());

  final SignOutUseCase _signOutUseCase;

  @override
  Future<void> signOut() async {
    emit(SignOutLoading());
    var result = await _signOutUseCase();
    switch (result) {
      case NetworkSuccess<void>():
        emit(SignOutSuccess());
      case NetworkFailure<void>():
        emit(SignOutFailure(getErrorMessage(result).tr()));
    }
  }
}
