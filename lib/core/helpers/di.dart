import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service_imp.dart';
import 'package:fruit_hub/core/services/location/location_service.dart';
import 'package:fruit_hub/core/services/notifications/notification_service.dart';
import 'package:fruit_hub/core/theming/app_theme_cubit.dart';
import 'package:fruit_hub/features/auth/data/data_sources/remote/auth_remote_data_source_imp.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/get_user_info_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/forget_password_cubit/forget_password_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signin_cubit/sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signup_cubit/sign_up_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source_imp.dart';
import 'package:fruit_hub/features/cart/data/repo_imp/cart_repo_imp.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
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
import 'package:fruit_hub/features/favorites/data/data_sources/remote/favorites_remote_data_source_imp.dart';
import 'package:fruit_hub/features/favorites/data/repo_imp/favorites_repo_imp.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/remove_item_from_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
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
import 'package:fruit_hub/features/reviews/data/data_sources/remote/reviews_remote_data_source.dart';
import 'package:fruit_hub/features/reviews/data/data_sources/remote/reviews_remote_data_source_imp.dart';
import 'package:fruit_hub/features/reviews/data/repo_imp/reviews_repo_imp.dart';
import 'package:fruit_hub/features/reviews/domain/repo/reviews_repo.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/add_review_use_case.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/check_user_purchased_product_use_case.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:fruit_hub/features/search/data/data_sources/remote/search_remote_data_source_imp.dart';
import 'package:fruit_hub/features/search/data/repo_imp/search_repo_imp.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:fruit_hub/features/search/presentation/managers/search_cubit/search_cubit.dart';
import 'package:fruit_hub/features/splash/presentation/managers/splash_cubit/splash_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  /// App Preferences Service
  getIt.registerSingletonAsync<AppPreferencesService>(() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return AppPreferencesServiceImpl(sharedPreferences);
  });

  /// Location Service
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  /// Notifications Service
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  /// Theming
  getIt.registerLazySingleton<AppThemeCubit>(
    () => AppThemeCubit(getIt<AppPreferencesService>()),
  );

  getIt.registerSingleton<AuthRepoImp>(AuthRepoImp(AuthRemoteDataSourceImp()));

  getIt.registerSingleton<SignInWithEmailAndPasswordUseCase>(
    SignInWithEmailAndPasswordUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerSingleton<CreateUserWithEmailAndPasswordUseCase>(
    CreateUserWithEmailAndPasswordUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerSingleton<GoogleSignInUseCase>(
    GoogleSignInUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerSingleton<FacebookSignInUseCase>(
    FacebookSignInUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerSingleton<ForgetPasswordUseCase>(
    ForgetPasswordUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerSingleton<GetUserInfoUseCase>(
    GetUserInfoUseCase(getIt<AuthRepoImp>()),
  );

  getIt.registerSingleton<SignOutUseCase>(SignOutUseCase(getIt<AuthRepoImp>()));

  /// Splash & Onboarding
  getIt.registerFactory<SplashCubit>(
    () => SplashCubit(getIt<AppPreferencesService>()),
  );

  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(getIt<AppPreferencesService>()),
  );

  /// Auth Cubits
  getIt.registerLazySingleton<UserInfoCubit>(
    () => UserInfoCubit(
      getIt<AppPreferencesService>(),
      getIt<GetUserInfoUseCase>(),
    ),
  );

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

  getIt.registerSingleton<ClearCartUseCase>(
    ClearCartUseCase(getIt<CartRepoImp>()),
  );

  getIt.registerFactory<CartCubit>(
    () => CartCubit(
      getIt<AddItemToCartUseCase>(),
      getIt<RemoveItemFromCartUseCase>(),
      getIt<GetProductsInCartUseCase>(),
      getIt<UpdateItemQuantityUseCase>(),
      getIt<ClearCartUseCase>(),
    ),
  );

  /// Favorites
  ////////////////////////////
  getIt.registerSingleton<FavoritesRepoImp>(
    FavoritesRepoImp(FavoritesRemoteDataSourceImp()),
  );

  getIt.registerSingleton<GetFavoritesUseCase>(
    GetFavoritesUseCase(getIt<FavoritesRepoImp>()),
  );

  getIt.registerSingleton<GetFavoriteIdsUseCase>(
    GetFavoriteIdsUseCase(getIt<FavoritesRepoImp>()),
  );

  getIt.registerSingleton<AddItemToFavoritesUseCase>(
    AddItemToFavoritesUseCase(getIt<FavoritesRepoImp>()),
  );

  getIt.registerSingleton<RemoveItemFromFavoritesUseCase>(
    RemoveItemFromFavoritesUseCase(getIt<FavoritesRepoImp>()),
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
    CheckoutRepoImp(CheckoutRemoteDataSourceImp()),
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

  /// Reviews
  ////////////////////////////
  getIt.registerSingleton<ReviewsRemoteDataSource>(
    ReviewsRemoteDataSourceImp(),
  );

  getIt.registerSingleton<ReviewsRepo>(
    ReviewsRepoImp(getIt<ReviewsRemoteDataSource>()),
  );

  getIt.registerSingleton<CheckUserPurchasedProductUseCase>(
    CheckUserPurchasedProductUseCase(getIt<ReviewsRepo>()),
  );

  getIt.registerSingleton<AddReviewUseCase>(
    AddReviewUseCase(getIt<ReviewsRepo>()),
  );

  getIt.registerFactoryParam<ReviewsCubit, FruitEntity, void>(
    (fruit, _) => ReviewsCubit(
      checkUserPurchasedProductUseCase:
          getIt<CheckUserPurchasedProductUseCase>(),
      addReviewUseCase: getIt<AddReviewUseCase>(),
      fruit: fruit,
    ),
  );
}
