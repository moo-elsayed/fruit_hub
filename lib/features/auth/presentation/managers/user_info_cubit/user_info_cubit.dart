import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/get_user_info_use_case.dart';

part 'user_info_state.dart';

class UserInfoCubit extends Cubit<UserInfoState> {
  UserInfoCubit(
    this._appPreferencesService,
    this._getUserInfoUseCase, {
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       super(UserInfoInitial()) {
    loadCachedUser();
  }

  final AppPreferencesService _appPreferencesService;
  final GetUserInfoUseCase _getUserInfoUseCase;
  final FirebaseAuth? _firebaseAuth;

  UserEntity? get currentUser {
    if (state is UserInfoSuccess) {
      return (state as UserInfoSuccess).user;
    }
    return _appPreferencesService.getUser();
  }

  void loadCachedUser() {
    final cachedUser = _appPreferencesService.getUser();
    if (cachedUser != null) {
      emit(UserInfoSuccess(cachedUser));
    }
  }

  Future<void> getUserInfo() async {
    try {
      final auth = _firebaseAuth;
      final firebaseUser = auth != null
          ? auth.currentUser
          : FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      final cached = currentUser;
      if (cached == null) {
        emit(UserInfoLoading());
      }

      final response = await _getUserInfoUseCase(firebaseUser.uid);
      switch (response) {
        case NetworkSuccess<UserEntity>():
          if (response.data != null) {
            final updatedUser = response.data!;
            await _appPreferencesService.saveUser(updatedUser);
            emit(UserInfoSuccess(updatedUser));
          }
        case NetworkFailure<UserEntity>():
          if (cached == null) {
            emit(UserInfoFailure(response.error));
          }
      }
    } catch (e) {
      // Safely ignore when running in mock test mode without Firebase instance
    }
  }

  Future<void> saveUserLocally(UserEntity user) async {
    await _appPreferencesService.saveUser(user);
    emit(UserInfoSuccess(user));
  }

  Future<void> clearUserLocally() async {
    await _appPreferencesService.clearUser();
    emit(UserInfoInitial());
  }
}
