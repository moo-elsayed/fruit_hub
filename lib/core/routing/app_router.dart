import 'package:flutter/cupertino.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/animated_splash_view.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    //this arguments to be passed in any screen like this ( arguments as ClassName )
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.splashView:
        return CupertinoPageRoute(
          builder: (context) => const AnimatedSplashView(),
        );
      case Routes.onboardingView:
        return CupertinoPageRoute(builder: (context) => const OnboardingView());
      case Routes.loginView:
        return CupertinoPageRoute(builder: (context) => const LoginView());
      case Routes.registerView:
        return CupertinoPageRoute(builder: (context) => const RegisterView());
      default:
        return null;
    }
  }
}
