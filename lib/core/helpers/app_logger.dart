import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: SimplePrinter(colors: true, printTime: false),
  );

  static void info(String message) => _logger.i(message);

  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void debug(String message) => _logger.d(message);
}
