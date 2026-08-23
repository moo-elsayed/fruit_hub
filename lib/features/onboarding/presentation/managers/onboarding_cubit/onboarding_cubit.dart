import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._appPreferencesService) : super(OnboardingInitial());
  final AppPreferencesService _appPreferencesService;

  Future<void> setFirstTime(bool value) async {
    await _appPreferencesService.saveFirstTime();
    emit(OnboardingNavigateToHome());
  }
}
