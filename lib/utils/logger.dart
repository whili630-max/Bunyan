import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('Error: $message');
      if (error != null) debugPrint('Details: $error');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('Info: $message');
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      debugPrint('Warning: $message');
    }
  }
}

void main() {
  Logger.log('This is a log message');
  Logger.error('This is an error message', 'Some error', StackTrace.current);
  Logger.info('This is an info message');
  Logger.warn('This is a warning message');
}
