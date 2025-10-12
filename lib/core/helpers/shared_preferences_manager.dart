import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static late SharedPreferences _prefs;

  static const String isFirstTimeKey = 'isFirstTime';
  static const String usernameKey = 'username';
  static const String isLoggedInKey = 'isLoggedIn';

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static Future<void> setFirstTime(bool isFirstTime) async =>
      await _prefs.setBool(isFirstTimeKey, isFirstTime);

  static bool getFirstTime() => _prefs.getBool(isFirstTimeKey) ?? true;

  static Future<void> setUsername(String username) async =>
      await _prefs.setString(usernameKey, username);

  static String getUsername() => _prefs.getString(usernameKey) ?? '';

  static Future<void> setLoggedIn(bool isLoggedIn) async =>
      await _prefs.setBool(isLoggedInKey, isLoggedIn);

  static bool getLoggedIn() => _prefs.getBool(isLoggedInKey) ?? false;
}
