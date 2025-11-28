import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager implements LocalStorageService {
  late SharedPreferences _prefs;
  final String _isFirstTimeKey = 'isFirstTime';
  final String _isLoggedInKey = 'isLoggedIn';
  final String _usernameKey = 'username';
  final String _userAddressKey = 'userAddress';

  @override
  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  @override
  Future<void> setFirstTime(bool isFirstTime) async =>
      await _prefs.setBool(_isFirstTimeKey, isFirstTime);

  @override
  bool getFirstTime() => _prefs.getBool(_isFirstTimeKey) ?? true;

  @override
  Future<void> setLoggedIn(bool isLoggedIn) async =>
      await _prefs.setBool(_isLoggedInKey, isLoggedIn);

  @override
  bool getLoggedIn() => _prefs.getBool(_isLoggedInKey) ?? false;

  @override
  Future<void> setUsername(String username) async =>
      await _prefs.setString(_usernameKey, username);

  @override
  String getUsername() => _prefs.getString(_usernameKey) ?? '';

  @override
  Future<void> deleteUseName() async => await _prefs.remove(_usernameKey);

  @override
  Future<void> saveAddress(Map<String, dynamic> address) async =>
      await _prefs.setString(_userAddressKey, address.toString());

  @override
  String getAddress() => _prefs.getString(_userAddressKey) ?? '';

  @override
  Future<void> deleteAddress() async => await _prefs.remove(_userAddressKey);
}
