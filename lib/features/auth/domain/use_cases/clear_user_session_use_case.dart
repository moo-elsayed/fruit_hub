import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import '../../../../core/helpers/app_logger.dart';

class ClearUserSessionUseCase {
  ClearUserSessionUseCase(this._appPreferencesManager);

  final AppPreferencesManager _appPreferencesManager;

  Future<void> call() async {
    try {
      await Future.wait([
        _appPreferencesManager.deleteUid(),
        _appPreferencesManager.deleteUseName(),
        _appPreferencesManager.setLoggedIn(false),
        _appPreferencesManager.deleteAddress(),
      ]);
    } catch (e) {
      AppLogger.error("error in clear user session", error: e.toString());
      throw Exception('Failed to clear user session');
    }
  }
}
