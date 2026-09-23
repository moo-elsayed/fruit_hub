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
      return NetworkFailure(failureFromException(e));
    }
  }

  static Failure failureFromException(Object error) {
    if (error is BusinessException) {
      return ServerFailure(error: error.message);
    }
    return ServerFailure.fromException(error);
  }
}
