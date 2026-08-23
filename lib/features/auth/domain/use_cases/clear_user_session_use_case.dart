import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import '../../../../core/helpers/app_logger.dart';

class ClearUserSessionUseCase {
  ClearUserSessionUseCase(this._appPreferencesService);

  final AppPreferencesService _appPreferencesService;

  Future<void> call() async {
    try {
      await Future.wait([
        _appPreferencesService.clearUser(),
        _appPreferencesService.deleteAddress(),
      ]);
    } catch (e) {
      AppLogger.error('error in clear user session', error: e.toString());
      throw Exception('Failed to clear user session');
    }
  }
}
