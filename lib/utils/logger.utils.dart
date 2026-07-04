import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

// Create enum
enum LogType { info, warning, error, fatal }

class LoggerUtils {
  // Singleton biar file & logger gak dibuat ulang tiap kali dipanggil
  static final LoggerUtils _instance = LoggerUtils._internal();
  factory LoggerUtils() => _instance;
  LoggerUtils._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());
  final Logger _dataLogger = Logger(
    printer: PrettyPrinter(),
    level: Level.debug,
  );

  File? _logFile;

  Future<File?> _getLogFile() async {
    if (_logFile != null) return _logFile;
    try {
      final dir = await getApplicationSupportDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      _logFile = File('${logDir.path}/app-$dateStr.log');
      return _logFile;
    } catch (e) {
      _logger.e("Failed to init log file: $e");
      return null;
    }
  }

  Future<void> _writeToFile(String line) async {
    try {
      final file = await _getLogFile();
      if (file == null) return;
      await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    } catch (_) {
      // Sengaja ditelan — jangan sampai proses logging bikin app crash
    }
  }

  void log(
    String message,
    LogType type, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // 1. Console (pretty, buat development)
    switch (type) {
      case LogType.info:
        _logger.i(message, error: error, stackTrace: stackTrace);
        break;
      case LogType.warning:
        _logger.w(message, error: error, stackTrace: stackTrace);
        break;
      case LogType.error:
        _logger.e(message, error: error, stackTrace: stackTrace);
        break;
      case LogType.fatal:
        _logger.f(message, error: error, stackTrace: stackTrace);
        break;
    }

    // 2. File (plain text + detail, buat baca log di PC client)
    final ts = DateTime.now().toIso8601String();
    final buffer = StringBuffer('$ts [${type.name.toUpperCase()}] $message');
    if (error != null) buffer.write(' | error: $error');
    if (stackTrace != null) buffer.write('\n$stackTrace');
    _writeToFile(buffer.toString());
  }

  void dataLog(dynamic data) {
    _dataLogger.d(data);
  }
}
