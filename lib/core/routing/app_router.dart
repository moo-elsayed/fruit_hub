import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/auth/presentation/args/login_args.dart';
import 'package:fruit_hub/features/auth/presentation/views/forget_password_view.dart';
import 'package:fruit_hub/features/auth/presentation/views/login_view.dart';
import 'package:fruit_hub/features/auth/presentation/views/register_view.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/args/location_picker_args.dart';
import 'package:fruit_hub/features/checkout/presentation/views/checkout_view.dart';
import 'package:fruit_hub/features/checkout/presentation/views/location_picker_view.dart';
import 'package:fruit_hub/features/checkout/presentation/views/order_success_view.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/main/presentation/views/main_view.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/views/product_details_view.dart';
import 'package:fruit_hub/features/products/presentation/views/products_view.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/views/reviews_view.dart';
import 'package:fruit_hub/features/search/presentation/views/search_view.dart';
import 'package:fruit_hub/features/splash/presentation/views/animated_splash_view.dart';

class AppRouter {
  RouteSettings? _currentSettings;

  CartCubit? _cartCubit;
  FavoriteCubit? _favoriteCubit;

  CartCubit get _getCartCubit =>
      _cartCubit ??= getIt.get<CartCubit>()
        ..getProductsInCart(needLoading: false);

  FavoriteCubit get _getFavoriteCubit =>
      _favoriteCubit ??= getIt.get<FavoriteCubit>()..getFavorites();

  void _resetAuthenticatedCubits() {
    _cartCubit?.close();
    _cartCubit = null;
    _favoriteCubit?.close();
    _favoriteCubit = null;
  }

  Route? generateRoute(RouteSettings settings) {
    _currentSettings = settings;

    switch (settings.name) {
      case Routes.splashView:
        return _route(const AnimatedSplashView());
      case Routes.onboardingView:
        return _route(const OnboardingView());
      case Routes.loginView:
        _resetAuthenticatedCubits();
        final args = settings.arguments as LoginArgs?;
        return _route(LoginView(loginArgs: args));
      case Routes.registerView:
        return _route(const RegisterView());
      case Routes.forgetPasswordView:
        return _route(const ForgetPasswordView());
      case Routes.mainView:
        final initialIndex = settings.arguments as int? ?? 0;
        return _route(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _getCartCubit),
              BlocProvider.value(value: _getFavoriteCubit),
            ],
            child: MainView(initialIndex: initialIndex),
          ),
        );
      case Routes.productsView:
        return _route(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _getCartCubit),
              BlocProvider.value(value: _getFavoriteCubit),
              BlocProvider(create: (context) => getIt.get<ProductsCubit>()),
            ],
            child: const ProductsView(),
          ),
        );
      case Routes.searchView:
        return _route(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _getCartCubit),
              BlocProvider.value(value: _getFavoriteCubit),
            ],
            child: const SearchView(),
          ),
        );
      case Routes.productDetailsView:
        FruitEntity? fruitArg;
        String? codeArg;
        if (settings.arguments is FruitEntity) {
          fruitArg = settings.arguments as FruitEntity;
        } else if (settings.arguments is String) {
          codeArg = settings.arguments as String;
        }

        return _route(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _getCartCubit),
              BlocProvider.value(value: _getFavoriteCubit),
              BlocProvider(create: (context) => getIt.get<ProductsCubit>()),
            ],
            child: ProductDetailsView(
              fruitEntity: fruitArg,
              fruitCode: codeArg,
            ),
          ),
        );
      case Routes.checkoutView:
        final args = settings.arguments as List<CartItemEntity>;
        return _route(
          BlocProvider.value(
            value: _getCartCubit,
            child: CheckoutView(cartItems: args),
          ),
        );
      case Routes.orderSuccessView:
        final args = settings.arguments as OrderEntity;
        return _route(OrderSuccessView(orderEntity: args));
      case Routes.locationPickerView:
        final args = settings.arguments as LocationPickerArgs?;
        return _route(
          LocationPickerView(
            initialLatitude: args?.latitude,
            initialLongitude: args?.longitude,
          ),
        );
      case Routes.reviewsView:
        final fruit = settings.arguments as FruitEntity;
        return _route(
          BlocProvider(
            create: (context) => getIt.get<ReviewsCubit>(param1: fruit),
            child: ReviewsView(fruit: fruit),
          ),
        );
      default:
        return null;
    }
  }

  PageRouteBuilder<dynamic> _route(Widget view) => PageRouteBuilder(
    settings: _currentSettings,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => view,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideTween = Tween<Offset>(
        begin: const Offset(0.08, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      final fadeTween = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        ),
      );
    },
  );
}
