import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: SimplePrinter(colors: true, printTime: false),
  );

  static final Logger _errorLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void info(String message) => _logger.i(message);

  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _errorLogger.e(message, error: error, stackTrace: stackTrace);

  static void debug(String message) => _logger.d(message);
}
