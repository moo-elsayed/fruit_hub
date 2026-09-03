import 'dart:convert';

import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences_service.dart';

class AppPreferencesServiceImpl implements AppPreferencesService {
  AppPreferencesServiceImpl(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyUser = 'cached_user';
  static const String _keyUserAddress = 'user_address';

  @override
  Future<void> saveFirstTime() async =>
      await _sharedPreferences.setBool(_keyIsFirstTime, false);

  @override
  bool isFirstTime() => _sharedPreferences.getBool(_keyIsFirstTime) ?? true;

  @override
  Future<void> saveThemeMode(String theme) async =>
      await _sharedPreferences.setString(_keyThemeMode, theme);

  @override
  String getThemeMode() =>
      _sharedPreferences.getString(_keyThemeMode) ?? 'system';

  @override
  String getLanguage() => _sharedPreferences.getString(_keyLanguage) ?? 'ar';

  @override
  Future<void> saveLanguage(String lang) async =>
      await _sharedPreferences.setString(_keyLanguage, lang);

  @override
  Future<void> saveUser(UserEntity user) async {
    final userMap = UserModel.fromUserEntity(user).toJson();
    final jsonString = jsonEncode(userMap);
    await _sharedPreferences.setString(_keyUser, jsonString);
  }

  @override
  UserEntity? getUser() {
    final jsonString = _sharedPreferences.getString(_keyUser);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(map).toUserEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _sharedPreferences.remove(_keyUser);
  }

  @override
  Future<void> saveAddress(Map<String, dynamic> address) async {
    final addressJson = jsonEncode(address);
    await _sharedPreferences.setString(_keyUserAddress, addressJson);
  }

  @override
  String getAddress() => _sharedPreferences.getString(_keyUserAddress) ?? '';

  @override
  Future<void> deleteAddress() async =>
      await _sharedPreferences.remove(_keyUserAddress);
}
