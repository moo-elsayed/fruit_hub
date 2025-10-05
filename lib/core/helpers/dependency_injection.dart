import 'package:fruit_hub/features/auth/data/firebase/auth_firebase.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/data_sources/remote/auth_remote_data_source_imp.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/repo/repo_imp.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import '../../features/auth/domain/use_cases/google_sign_in_use_case.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  /// auth
  getIt.registerSingleton<AuthRepoImp>(
    AuthRepoImp(AuthRemoteDataSourceImp(AuthFirebase.instance)),
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

  ////////////////////////////
}
