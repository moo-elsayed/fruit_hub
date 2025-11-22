import 'package:fruit_hub/core/helpers/app_logger.dart';
import '../../../../core/services/local_storage/local_storage_service.dart';
import '../entities/user_entity.dart';

class SaveUserSessionUseCase {
  final LocalStorageService _localStorageService;

  SaveUserSessionUseCase(this._localStorageService);

  Future<void> call(UserEntity user) async {
    try {
      await Future.wait([
        _localStorageService.setUsername(user.name),
        _localStorageService.setLoggedIn(true),
      ]);
    } catch (e) {
      AppLogger.error("error in save user session", error: e.toString());
      throw Exception('Failed to save user session');
    }
  }
}
