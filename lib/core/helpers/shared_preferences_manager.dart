import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static late SharedPreferences _prefs;

  static const String isFirstTimeKey = 'isFirstTime';

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static Future<void> setFirstTime(bool isFirstTime) async =>
      await _prefs.setBool(isFirstTimeKey, isFirstTime);

  static Future<bool> getFirstTime() async =>
      _prefs.getBool(isFirstTimeKey) ?? true;
}
