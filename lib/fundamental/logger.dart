/// アプリケーション全体で使用するシンプルなログ機能
library;

import 'dart:developer' as developer;

/// ログレベルの列挙型
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// シンプルなロガークラス
class Logger {
  Logger(this.name);

  final String name;

  /// デバッグログ
  void debug(String message) {
    _log(LogLevel.debug, message);
  }

  /// 情報ログ
  void info(String message) {
    _log(LogLevel.info, message);
  }

  /// 警告ログ
  void warning(String message) {
    _log(LogLevel.warning, message);
  }

  /// エラーログ
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final prefix = '[${level.name.toUpperCase()}][$name]';
    developer.log(
      '$prefix $message',
      name: name,
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _levelToInt(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    };
  }
}
