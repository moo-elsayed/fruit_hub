import 'package:flutter/cupertino.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/app_section/presentation/views/app_section.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:fruit_hub/features/products/presentation/views/product_details_view.dart';
import 'package:fruit_hub/features/search/presentation/views/search_view.dart';
import '../../features/auth/presentation/args/login_args.dart';
import '../../features/auth/presentation/views/forget_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/splash/presentation/views/animated_splash_view.dart';

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
        final args = arguments as LoginArgs?;
        return CupertinoPageRoute(
          builder: (context) => LoginView(loginArgs: args),
        );
      case Routes.registerView:
        return CupertinoPageRoute(builder: (context) => const RegisterView());
      case Routes.forgetPasswordView:
        return CupertinoPageRoute(
          builder: (context) => const ForgetPasswordView(),
        );
      case Routes.appSection:
        return CupertinoPageRoute(builder: (context) => const AppSection());
      case Routes.searchView:
        return CupertinoPageRoute(builder: (context) => const SearchView());
      case Routes.productDetailsView:
        final args = arguments as FruitEntity;
        return CupertinoPageRoute(
          builder: (context) => ProductDetailsView(fruitEntity: args),
        );
      // case Routes.bestSellerView:
      //   return CupertinoPageRoute(
      //     builder: (context) => const BestSellerView(),
      //   );
      default:
        return null;
    }
  }
}
