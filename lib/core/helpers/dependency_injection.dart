import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/home/data/data_sources/remote/home_remote_data_source_imp.dart';
import 'package:fruit_hub/features/home/data/repo_imp/home_repo_imp.dart';
import 'package:fruit_hub/features/products/data/data_sources/products_remote_data_source_imp.dart';
import 'package:fruit_hub/features/products/data/repo_imp/home_repo_imp.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:fruit_hub/features/search/data/data_sources/search_remote_data_source_imp.dart';
import 'package:fruit_hub/features/search/data/repo_imp/search_repo_imp.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/data_sources/remote/auth_remote_data_source_imp.dart';
import '../../features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import '../../features/auth/domain/use_cases/forget_password_use_case.dart';
import '../../features/auth/domain/use_cases/google_sign_in_use_case.dart';
import '../services/authentication/auth_service.dart';
import '../../shared_data/services/authentication/firebase_auth_service.dart';
import '../services/database/database_service.dart';
import '../../shared_data/services/database/firestore_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  /// auth
  getIt.registerSingleton<AuthService>(
    FirebaseAuthService(FirebaseAuth.instance, GoogleSignIn.instance),
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

  ////////////////////////////

  getIt.registerSingleton<HomeRepoImp>(
    HomeRepoImp(HomeRemoteDataSourceImp(getIt.get<DatabaseService>())),
  );

  getIt.registerSingleton<GetBestSellerProductsUseCase>(
    GetBestSellerProductsUseCase(getIt<HomeRepoImp>()),
  );

  ////////////////////////////

  getIt.registerSingleton<ProductsRepoImp>(
    ProductsRepoImp(ProductsRemoteDataSourceImp(getIt.get<DatabaseService>())),
  );
  getIt.registerSingleton<GetAllProductsUseCase>(
    GetAllProductsUseCase(getIt<ProductsRepoImp>()),
  );

  ////////////////////////////

  getIt.registerSingleton<SearchRepoImp>(
    SearchRepoImp(SearchRemoteDataSourceImp(getIt.get<DatabaseService>())),
  );

  getIt.registerSingleton<SearchFruitsUseCase>(
    SearchFruitsUseCase(getIt<SearchRepoImp>()),
  );
}
