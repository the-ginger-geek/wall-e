import 'dart:io';

class Logger {
  static Logger? _instance;

  final _logFile = File('server.log');

  Logger._();

  static Logger init() {
    if (_instance == null) {
      _instance = Logger._();

      // Initialize the logger, e.g., create a log file if it doesn't exist
      _instance!.clearLogs();
      _instance!._logFile.createSync();
    }

    return _instance!;
  }

  void clearLogs() {
    final logFile = File('server.log');
    if (logFile.existsSync()) {
      logFile.deleteSync();
    }
  }

  // Write logs to a file in the current directory
  static void writeLog(String message) {
    final logMessage = '${DateTime.now()}: $message\n';
    print(logMessage);

    _instance?._logFile.writeAsStringSync(
      logMessage,
      mode: FileMode.append,
    );
  }
}
