import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._localStorageService) : super(OnboardingInitial());
  final LocalStorageService _localStorageService;

  Future<void> setFirstTime(bool value) async {
    await _localStorageService.setFirstTime(value);
    emit(OnboardingNavigateToHome());
  }
}
