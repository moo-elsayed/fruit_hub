import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._appPreferencesService, {FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      super(const SplashInitial());

  final AppPreferencesService _appPreferencesService;
  final FirebaseAuth _firebaseAuth;

  Future<void> checkAppStatus() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (isClosed) return;

    final isFirstTime = _appPreferencesService.isFirstTime();

    if (isFirstTime) {
      emit(
        const SplashNavigationState(navigation: SplashNavigation.onboarding),
      );
      return;
    }

    final isUserLoggedIn = _firebaseAuth.currentUser != null;

    if (isUserLoggedIn) {
      emit(const SplashNavigationState(navigation: SplashNavigation.home));
    } else {
      emit(const SplashNavigationState(navigation: SplashNavigation.login));
    }
  }
}
