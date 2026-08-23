import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service_imp.dart';
import 'package:fruit_hub/core/services/payment/payment_service.dart';
import 'package:fruit_hub/core/theming/app_theme_cubit.dart';
import 'package:fruit_hub/features/auth/data/data_sources/remote/auth_remote_data_source_imp.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/clear_user_session_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/save_user_session_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/forget_password_cubit/forget_password_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signin_cubit/sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signup_cubit/sign_up_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source_imp.dart';
import 'package:fruit_hub/features/cart/data/repo_imp/cart_repo_imp.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_cart_items_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source_imp.dart';
import 'package:fruit_hub/features/checkout/data/repo_imp/checkout_repo_imp.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/add_order_use_case.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/fetch_shipping_config_use_case.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/make_payment_use_case.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/home/data/data_sources/remote/home_remote_data_source_imp.dart';
import 'package:fruit_hub/features/home/data/repo_imp/home_repo_imp.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:fruit_hub/features/products/data/data_sources/remote/products_remote_data_source_imp.dart';
import 'package:fruit_hub/features/products/data/repo_imp/products_repo_imp.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_product_details_use_case.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source_imp.dart';
import 'package:fruit_hub/features/profile/data/repo_imp/profile_repo_imp.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/remove_item_from_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/search/data/data_sources/remote/search_remote_data_source_imp.dart';
import 'package:fruit_hub/features/search/data/repo_imp/search_repo_imp.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:fruit_hub/features/search/presentation/managers/search_cubit/search_cubit.dart';
import 'package:fruit_hub/features/splash/presentation/managers/splash_cubit/splash_cubit.dart';
import 'package:fruit_hub/shared_data/services/payment/stripe_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  /// App Preferences Service
  getIt.registerSingletonAsync<AppPreferencesService>(() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return AppPreferencesServiceImpl(sharedPreferences);
  });

  /// Theming
  getIt.registerFactory<AppThemeCubit>(
    () => AppThemeCubit(getIt<AppPreferencesService>()),
  );

  getIt.registerSingleton<PaymentService>(
    StripeService(Dio(), Stripe.instance),
  );

  getIt.registerSingleton<AuthRepoImp>(AuthRepoImp(AuthRemoteDataSourceImp()));

  getIt.registerLazySingleton<SaveUserSessionUseCase>(
    () => SaveUserSessionUseCase(getIt<AppPreferencesService>()),
  );

  getIt.registerLazySingleton<ClearUserSessionUseCase>(
    () => ClearUserSessionUseCase(getIt<AppPreferencesService>()),
  );

  getIt.registerLazySingleton<SignInWithEmailAndPasswordUseCase>(
    () => SignInWithEmailAndPasswordUseCase(
      getIt<AuthRepoImp>(),
      getIt.get<SaveUserSessionUseCase>(),
    ),
  );

  getIt.registerSingleton<CreateUserWithEmailAndPasswordUseCase>(
    CreateUserWithEmailAndPasswordUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerLazySingleton<GoogleSignInUseCase>(
    () => GoogleSignInUseCase(
      getIt<AuthRepoImp>(),
      getIt.get<SaveUserSessionUseCase>(),
    ),
  );

  getIt.registerLazySingleton<FacebookSignInUseCase>(
    () => FacebookSignInUseCase(
      getIt<AuthRepoImp>(),
      getIt.get<SaveUserSessionUseCase>(),
    ),
  );

  getIt.registerSingleton<ForgetPasswordUseCase>(
    ForgetPasswordUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(
      getIt<AuthRepoImp>(),
      getIt.get<ClearUserSessionUseCase>(),
    ),
  );

  /// Splash & Onboarding
  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(getIt<AppPreferencesService>()),
  );

  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(getIt<AppPreferencesService>()),
  );

  /// Auth Cubits
  getIt.registerFactory<SignInCubit>(
    () => SignInCubit(getIt<SignInWithEmailAndPasswordUseCase>()),
  );

  getIt.registerFactory<SignupCubit>(
    () => SignupCubit(getIt<CreateUserWithEmailAndPasswordUseCase>()),
  );

  getIt.registerFactory<SocialSignInCubit>(
    () => SocialSignInCubit(
      getIt<GoogleSignInUseCase>(),
      getIt<FacebookSignInUseCase>(),
    ),
  );

  getIt.registerFactory<ForgetPasswordCubit>(
    () => ForgetPasswordCubit(getIt<ForgetPasswordUseCase>()),
  );

  getIt.registerFactory<SignOutCubit>(
    () => SignOutCubit(getIt<SignOutUseCase>()),
  );

  /// Home
  ////////////////////////////
  getIt.registerSingleton<HomeRepoImp>(HomeRepoImp(HomeRemoteDataSourceImp()));

  getIt.registerSingleton<GetBestSellerProductsUseCase>(
    GetBestSellerProductsUseCase(getIt<HomeRepoImp>()),
  );

  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getIt<GetBestSellerProductsUseCase>(),
      getIt<AppPreferencesService>(),
    ),
  );

  /// Products
  ////////////////////////////
  getIt.registerSingleton<ProductsRepoImp>(
    ProductsRepoImp(ProductsRemoteDataSourceImp()),
  );

  getIt.registerSingleton<GetAllProductsUseCase>(
    GetAllProductsUseCase(getIt<ProductsRepoImp>()),
  );

  getIt.registerSingleton<GetProductDetailsUseCase>(
    GetProductDetailsUseCase(getIt<ProductsRepoImp>()),
  );

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(
      getAllProductsUseCase: getIt<GetAllProductsUseCase>(),
      getProductDetailsUseCase: getIt<GetProductDetailsUseCase>(),
    ),
  );

  /// Search
  ////////////////////////////
  getIt.registerSingleton<SearchRepoImp>(
    SearchRepoImp(SearchRemoteDataSourceImp()),
  );

  getIt.registerSingleton<SearchFruitsUseCase>(
    SearchFruitsUseCase(getIt<SearchRepoImp>()),
  );

  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<SearchFruitsUseCase>()),
  );

  /// Cart
  ////////////////////////////
  getIt.registerSingleton<CartRepoImp>(CartRepoImp(CartRemoteDataSourceImp()));

  getIt.registerSingleton<GetProductsInCartUseCase>(
    GetProductsInCartUseCase(getIt<CartRepoImp>()),
  );

  getIt.registerSingleton<AddItemToCartUseCase>(
    AddItemToCartUseCase(getIt<CartRepoImp>()),
  );

  getIt.registerSingleton<RemoveItemFromCartUseCase>(
    RemoveItemFromCartUseCase(getIt<CartRepoImp>()),
  );

  getIt.registerSingleton<UpdateItemQuantityUseCase>(
    UpdateItemQuantityUseCase(getIt<CartRepoImp>()),
  );

  getIt.registerSingleton<GetCartItemsUseCase>(
    GetCartItemsUseCase(getIt<CartRepoImp>()),
  );

  getIt.registerSingleton<ClearCartUseCase>(
    ClearCartUseCase(getIt<CartRepoImp>()),
  );

  getIt.registerFactory<CartCubit>(
    () => CartCubit(
      getIt<AddItemToCartUseCase>(),
      getIt<RemoveItemFromCartUseCase>(),
      getIt<GetProductsInCartUseCase>(),
      getIt<UpdateItemQuantityUseCase>(),
      getIt<GetCartItemsUseCase>(),
      getIt<ClearCartUseCase>(),
    ),
  );

  /// Favorites
  ////////////////////////////
  getIt.registerSingleton<ProfileRepoImp>(
    ProfileRepoImp(ProfileRemoteDataSourceImp()),
  );

  getIt.registerSingleton<GetFavoritesUseCase>(
    GetFavoritesUseCase(getIt<ProfileRepoImp>()),
  );

  getIt.registerSingleton<GetFavoriteIdsUseCase>(
    GetFavoriteIdsUseCase(getIt<ProfileRepoImp>()),
  );

  getIt.registerSingleton<AddItemToFavoritesUseCase>(
    AddItemToFavoritesUseCase(getIt<ProfileRepoImp>()),
  );

  getIt.registerSingleton<RemoveItemFromFavoritesUseCase>(
    RemoveItemFromFavoritesUseCase(getIt<ProfileRepoImp>()),
  );

  getIt.registerFactory<FavoriteCubit>(
    () => FavoriteCubit(
      getIt<AddItemToFavoritesUseCase>(),
      getIt<RemoveItemFromFavoritesUseCase>(),
      getIt<GetFavoriteIdsUseCase>(),
      getIt<GetFavoritesUseCase>(),
    ),
  );

  /// Checkout
  ////////////////////////////
  getIt.registerSingleton<CheckoutRepo>(
    CheckoutRepoImp(
      CheckoutRemoteDataSourceImp(paymentService: getIt.get<PaymentService>()),
    ),
  );

  getIt.registerSingleton<FetchShippingConfigUseCase>(
    FetchShippingConfigUseCase(getIt<CheckoutRepo>()),
  );

  getIt.registerSingleton<AddOrderUseCase>(
    AddOrderUseCase(getIt<CheckoutRepo>()),
  );

  getIt.registerSingleton<MakePaymentUseCase>(
    MakePaymentUseCase(getIt<CheckoutRepo>()),
  );

  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      getIt<AppPreferencesService>(),
      getIt<FetchShippingConfigUseCase>(),
      getIt<AddOrderUseCase>(),
      getIt<MakePaymentUseCase>(),
    ),
  );
}
