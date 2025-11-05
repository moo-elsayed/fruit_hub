import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._localStorageService) : super(SplashInitial());

  final LocalStorageService _localStorageService;

  Future<void> checkAppStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_getFirstTime()) {
      emit(SplashNavigateToOnboarding());
      return;
    }

    if (_isLoggedIn()) {
      emit(SplashNavigateToHome());
    } else {
      emit(SplashNavigateToLogin());
    }
  }

  bool _getFirstTime() => _localStorageService.getFirstTime();

  bool _isLoggedIn() => _localStorageService.getLoggedIn();
}
