import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/save_user_session_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source_imp.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/home/data/data_sources/remote/home_remote_data_source_imp.dart';
import 'package:fruit_hub/features/home/data/repo_imp/home_repo_imp.dart';
import 'package:fruit_hub/features/products/data/data_sources/remote/products_remote_data_source_imp.dart';
import 'package:fruit_hub/features/products/data/repo_imp/products_repo_imp.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source_imp.dart';
import 'package:fruit_hub/features/profile/data/repo_imp/profile_repo_imp.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/remove_item_from_favorites_use_case.dart';
import 'package:fruit_hub/features/search/data/data_sources/remote/search_remote_data_source_imp.dart';
import 'package:fruit_hub/features/search/data/repo_imp/search_repo_imp.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:fruit_hub/shared_data/services/local_storage_service/shared_preferences_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/data_sources/remote/auth_remote_data_source_imp.dart';
import '../../features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import '../../features/auth/domain/use_cases/forget_password_use_case.dart';
import '../../features/auth/domain/use_cases/google_sign_in_use_case.dart';
import '../../features/cart/data/repo_imp/cart_repo_imp.dart';
import '../../features/cart/domain/use_cases/get_cart_items_use_case.dart';
import '../../features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import '../../features/cart/domain/use_cases/update_item_quantity_use_case.dart';
import '../../features/profile/domain/use_cases/get_favorites_use_case.dart';
import '../services/authentication/auth_service.dart';
import '../../shared_data/services/authentication/firebase_auth_service.dart';
import '../services/database/database_service.dart';
import '../../shared_data/services/database/firestore_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  /// local storage service
  getIt.registerSingletonAsync<LocalStorageService>(() async {
    final service = SharedPreferencesManager();
    await service.init();
    return service;
  });

  /// auth
  getIt.registerSingleton<AuthService>(
    FirebaseAuthService(
      FirebaseAuth.instance,
      GoogleSignIn.instance,
      FacebookAuth.instance,
    ),
  );

  getIt.registerSingleton<DatabaseService>(
    FirestoreService(FirebaseFirestore.instance),
  );

  getIt.registerSingleton<AuthRepoImp>(
    AuthRepoImp(
      AuthRemoteDataSourceImp(
        getIt.get<AuthService>(),
        getIt.get<DatabaseService>(),
      ),
    ),
  );

  getIt.registerLazySingleton<SaveUserSessionUseCase>(
    () => SaveUserSessionUseCase(getIt<LocalStorageService>()),
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

  /// Home
  ////////////////////////////

  getIt.registerSingleton<HomeRepoImp>(
    HomeRepoImp(HomeRemoteDataSourceImp(getIt.get<DatabaseService>())),
  );

  getIt.registerSingleton<GetBestSellerProductsUseCase>(
    GetBestSellerProductsUseCase(getIt<HomeRepoImp>()),
  );

  /// Products
  ////////////////////////////

  getIt.registerSingleton<ProductsRepoImp>(
    ProductsRepoImp(ProductsRemoteDataSourceImp(getIt.get<DatabaseService>())),
  );
  getIt.registerSingleton<GetAllProductsUseCase>(
    GetAllProductsUseCase(getIt<ProductsRepoImp>()),
  );

  /// Search
  ////////////////////////////

  getIt.registerSingleton<SearchRepoImp>(
    SearchRepoImp(SearchRemoteDataSourceImp(getIt.get<DatabaseService>())),
  );

  getIt.registerSingleton<SearchFruitsUseCase>(
    SearchFruitsUseCase(getIt<SearchRepoImp>()),
  );

  /// Cart
  ////////////////////////////

  getIt.registerSingleton<CartRepoImp>(
    CartRepoImp(
      CartRemoteDataSourceImp(
        getIt.get<DatabaseService>(),
        FirebaseAuth.instance,
      ),
    ),
  );

  getIt.registerSingleton<GetCartItemsUseCase>(
    GetCartItemsUseCase(getIt<CartRepoImp>()),
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

  /// favorites
  ////////////////////////////

  getIt.registerSingleton<ProfileRepoImp>(
    ProfileRepoImp(
      ProfileRemoteDataSourceImp(
        getIt.get<DatabaseService>(),
        FirebaseAuth.instance,
      ),
    ),
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
}
