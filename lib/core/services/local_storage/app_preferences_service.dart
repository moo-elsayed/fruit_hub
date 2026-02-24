abstract class AppPreferencesManager {
  Future<void> init();

  Future<void> setFirstTime(bool isFirstTime);

  bool getFirstTime();

  Future<void> setUid(String uid);

  String getUid();

  Future<void> deleteUid();

  Future<void> setUsername(String username);

  String getUsername();

  Future<void> deleteUseName();

  Future<void> setLoggedIn(bool isLoggedIn);

  bool getLoggedIn();

  Future<void> saveAddress(Map<String, dynamic> address);

  String getAddress();

  Future<void> deleteAddress();
}
