import 'package:fruit_hub/core/helpers/app_logger.dart';
import '../../../../core/services/local_storage/app_preferences_service.dart';
import '../entities/user_entity.dart';

class SaveUserSessionUseCase {
  SaveUserSessionUseCase(this._appPreferencesManager);

  final AppPreferencesManager _appPreferencesManager;

  Future<void> call(UserEntity user) async {
    try {
      await Future.wait([
        _appPreferencesManager.setUid(user.uid),
        _appPreferencesManager.setUsername(user.name),
        _appPreferencesManager.setLoggedIn(true),
      ]);
    } catch (e) {
      AppLogger.error("error in save user session", error: e.toString());
      throw Exception('Failed to save user session');
    }
  }
}
