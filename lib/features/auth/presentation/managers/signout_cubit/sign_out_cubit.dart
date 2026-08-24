import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';

part 'sign_out_state.dart';

class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit(this._signOutUseCase) : super(SignOutInitial());

  final SignOutUseCase _signOutUseCase;

  Future<void> signOut() async {
    emit(SignOutLoading());
    final result = await _signOutUseCase();
    switch (result) {
      case NetworkSuccess<void>():
        await getIt<UserInfoCubit>().clearUserLocally();
        emit(SignOutSuccess());
      case NetworkFailure<void>():
        emit(SignOutFailure(result.error));
    }
  }
}
