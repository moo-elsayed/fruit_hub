import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';

abstract class AppPreferencesService {
  Future<void> saveFirstTime();

  bool isFirstTime();

  Future<void> saveThemeMode(String theme);

  String getThemeMode();

  String getLanguage();

  Future<void> saveLanguage(String lang);

  Future<void> saveUser(UserEntity user);

  UserEntity? getUser();

  Future<void> clearUser();

  Future<void> saveAddress(Map<String, dynamic> address);

  String getAddress();

  Future<void> deleteAddress();
}
