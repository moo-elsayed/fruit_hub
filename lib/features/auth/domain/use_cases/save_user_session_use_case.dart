import 'package:fruit_hub/core/helpers/app_logger.dart';
import '../../../../core/services/local_storage/app_preferences_service.dart';
import '../entities/user_entity.dart';

class SaveUserSessionUseCase {
  SaveUserSessionUseCase(this._appPreferencesService);

  final AppPreferencesService _appPreferencesService;

  Future<void> call(UserEntity user) async {
    try {
      await _appPreferencesService.saveUser(user);
    } catch (e) {
      AppLogger.error('error in save user session', error: e.toString());
      throw Exception('Failed to save user session');
    }
  }
}
