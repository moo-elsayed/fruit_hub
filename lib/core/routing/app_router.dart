import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/models/order_model.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/utils/full_screen_image_gallery_input_item.dart';
import 'package:fruit_hub/core/widgets/full_screen_image_gallery.dart';
import 'package:fruit_hub/env.dart';
import 'package:fruit_hub/features/auth/presentation/args/login_args.dart';
import 'package:fruit_hub/features/auth/presentation/views/forget_password_view.dart';
import 'package:fruit_hub/features/auth/presentation/views/login_view.dart';
import 'package:fruit_hub/features/auth/presentation/views/register_view.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/args/location_picker_args.dart';
import 'package:fruit_hub/features/checkout/presentation/args/paypal_checkout_args.dart';
import 'package:fruit_hub/features/checkout/presentation/views/checkout_view.dart';
import 'package:fruit_hub/features/checkout/presentation/views/location_picker_view.dart';
import 'package:fruit_hub/features/checkout/presentation/views/order_success_view.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/main/presentation/views/main_view.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_cubit.dart';
import 'package:fruit_hub/features/notifications/presentation/views/notifications_view.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:fruit_hub/features/orders/presentation/views/orders_view.dart';
import 'package:fruit_hub/features/orders/presentation/views/track_order_view.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/views/product_details_view.dart';
import 'package:fruit_hub/features/products/presentation/views/products_view.dart';
import 'package:fruit_hub/features/profile/presentation/managers/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/views/edit_profile_view.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/views/reviews_view.dart';
import 'package:fruit_hub/features/search/presentation/views/search_view.dart';
import 'package:fruit_hub/features/splash/presentation/views/animated_splash_view.dart';

class AppRouter {
  RouteSettings? _currentSettings;

  CartCubit? _cartCubit;
  FavoriteCubit? _favoriteCubit;
  NotificationsCubit? _notificationsCubit;

  CartCubit get _getCartCubit =>
      _cartCubit ??= getIt.get<CartCubit>()
        ..getProductsInCart(needLoading: false);

  FavoriteCubit get _getFavoriteCubit =>
      _favoriteCubit ??= getIt.get<FavoriteCubit>()..getFavorites();

  NotificationsCubit get _getNotificationsCubit =>
      _notificationsCubit ??= getIt.get<NotificationsCubit>()
        ..initNotificationsStream();

  void _resetAuthenticatedCubits() {
    _cartCubit?.close();
    _cartCubit = null;
    _favoriteCubit?.close();
    _favoriteCubit = null;
    _notificationsCubit?.close();
    _notificationsCubit = null;
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
              BlocProvider.value(value: _getNotificationsCubit),
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
      case Routes.notificationsView:
        return _route(
          BlocProvider.value(
            value: _getNotificationsCubit,
            child: const NotificationsView(),
          ),
        );
      case Routes.ordersView:
        return _route(const OrdersView());
      case Routes.trackOrderView:
        OrderEntity? orderArg;
        String? orderIdArg;
        if (settings.arguments is OrderEntity) {
          orderArg = settings.arguments as OrderEntity;
        } else if (settings.arguments is String) {
          orderIdArg = settings.arguments as String;
        } else if (settings.arguments is int) {
          orderIdArg = settings.arguments.toString();
        }
        return _route(TrackOrderView(order: orderArg, orderId: orderIdArg));
      case Routes.paypalCheckoutView:
        final args = settings.arguments as PaypalCheckoutArgs;
        final orderModel = OrderModel.fromEntity(args.orderEntity);
        return _route(
          PaypalCheckoutView(
            sandboxMode: true,
            clientId: Env.paypalClientId,
            secretKey: Env.paypalSecretKey,
            transactions: [orderModel.toPaypalTransaction()],
            note: AppStrings.contactUsForAnyQuestionsOnYourOrder,
            onSuccess: args.onSuccess,
            onError: args.onError,
            onCancel: args.onCancel,
          ),
        );
      case Routes.fullScreenImageGalleryView:
        final item = settings.arguments as FullScreenImageGalleryInputItem;
        return _route(FullScreenImageGallery(item: item));
      case Routes.editProfileView:
        return _route(
          BlocProvider(
            create: (context) => getIt<EditProfileCubit>(),
            child: const EditProfileView(),
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
