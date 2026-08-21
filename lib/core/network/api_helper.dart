import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../helpers/app_logger.dart';
import 'network_response.dart';

class ApiHelper {
  ApiHelper._();

  static Future<NetworkResponse<T>> executeSafely<T>(
    Future<T> Function() action, {
    required String functionName,
  }) async {
    try {
      final result = await action();
      return NetworkSuccess(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error in $functionName',
        error: e,
        stackTrace: stackTrace,
      );
      if (e is BusinessException) {
        return NetworkFailure(ServerFailure(error: e.message));
      }
      return NetworkFailure(ServerFailure.fromException(e));
    }
  }
}
