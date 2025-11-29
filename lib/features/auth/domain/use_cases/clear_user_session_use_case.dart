import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import '../../../../core/helpers/app_logger.dart';

class ClearUserSessionUseCase {
  ClearUserSessionUseCase(this._localStorageService);

  final LocalStorageService _localStorageService;

  Future<void> call() async {
    try {
      await Future.wait([
        _localStorageService.deleteUseName(),
        _localStorageService.setLoggedIn(false),
        _localStorageService.deleteAddress(),
      ]);
    } catch (e) {
      AppLogger.error("error in clear user session", error: e.toString());
      throw Exception('Failed to clear user session');
    }
  }
}
