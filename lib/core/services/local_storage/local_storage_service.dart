abstract class LocalStorageService {
  Future<void> init();

  Future<void> setFirstTime(bool isFirstTime);

  bool getFirstTime();

  Future<void> setUsername(String username);

  String getUsername();

  Future<void> deleteUseName();

  Future<void> setLoggedIn(bool isLoggedIn);

  bool getLoggedIn();

  Future<void> saveAddress(Map<String, dynamic> address);

  String getAddress();

  Future<void> deleteAddress();
}
