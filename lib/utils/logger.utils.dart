import 'package:logger/logger.dart';

// Create enum
enum LogType { info, warning, error, fatal }

class LoggerUtils {
  var logger = Logger(
    filter: null,
    printer: PrettyPrinter(),
    output: null,
  );

  var dataLogger = Logger(
    filter: null,
    printer: PrettyPrinter(),
    output: null,
    level: Level.debug,
  );

  void log(String message, LogType type) {
    switch (type) {
      case LogType.info:
        logger.i(message);
        break;
      case LogType.warning:
        logger.w(message);
        break;
      case LogType.error:
        logger.e(message);
        break;
      case LogType.fatal:
        logger.f(message);
        break;
      default:
        break;
    }
  }

  void dataLog(dynamic data) {
    dataLogger.d(data);
  }
}
