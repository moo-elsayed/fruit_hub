part of 'splash_cubit.dart';

enum SplashNavigation {
  onboarding,
  login,
  home,
}

@immutable
abstract class SplashState {
  const SplashState();
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashNavigationState extends SplashState {
  const SplashNavigationState({required this.navigation});

  final SplashNavigation navigation;
}
