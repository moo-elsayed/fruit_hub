import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/app_section/presentation/views/app_section.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/views/checkout_view.dart';
import 'package:fruit_hub/features/checkout/presentation/views/order_success_view.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/views/product_details_view.dart';
import 'package:fruit_hub/features/search/presentation/views/search_view.dart';
import '../../features/auth/presentation/args/login_args.dart';
import '../../features/auth/presentation/views/forget_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/products/domain/use_cases/get_all_products_use_case.dart';
import '../../features/products/domain/use_cases/get_product_details_use_case.dart';
import '../../features/splash/presentation/views/animated_splash_view.dart';
import '../helpers/di.dart';

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
        FruitEntity? fruitArg;
        String? codeArg;
        if (arguments is FruitEntity) {
          fruitArg = arguments;
        } else if (arguments is String) {
          codeArg = arguments;
        }

        return CupertinoPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => ProductsCubit(
              getAllProductsUseCase: getIt.get<GetAllProductsUseCase>(),
              getProductDetailsUseCase: getIt.get<GetProductDetailsUseCase>(),
            ),
            child: ProductDetailsView(
              fruitEntity: fruitArg,
              fruitCode: codeArg,
            ),
          ),
        );
      case Routes.checkoutView:
        final args = arguments as List<CartItemEntity>;
        return CupertinoPageRoute(
          builder: (context) => CheckoutView(cartItems: args),
        );
      case Routes.orderSuccessView:
        final args = arguments as OrderEntity;
        return CupertinoPageRoute(
          builder: (context) => OrderSuccessView(orderEntity: args),
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
