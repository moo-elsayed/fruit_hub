import 'package:flutter/cupertino.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/animated_splash_view.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';

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
      default:
        return null;
    }
  }
}
