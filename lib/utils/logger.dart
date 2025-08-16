import 'package:flutter/foundation.dart';

/// Log levels for categorizing log messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// A generic logger utility for the DayNight app
/// 
/// Usage examples:
/// ```dart
/// // Basic logging
/// Logger.info('User logged in successfully');
/// Logger.debug('Processing user data', 'UserService');
/// Logger.warning('Network response delayed');
/// Logger.error('Failed to save user data', 'UserService', exception, stackTrace);
/// 
/// // With custom tags for better organization
/// Logger.debug('Fetching events from API', 'EventService');
/// Logger.info('Cache hit for user profile', 'CacheManager');
/// ```

class Logger {
  static const String _appName = 'DayNight';
  
  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }
  
  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }
  
  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }
  
  static void error(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      _log(LogLevel.error, 'Error details: $error', tag);
    }
    if (stackTrace != null) {
      _log(LogLevel.error, 'Stack trace: $stackTrace', tag);
    }
  }
  
  static void _log(LogLevel level, String message, String? tag) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final levelStr = level.toString().split('.').last.toUpperCase();
      final tagStr = tag != null ? '[$tag] ' : '';
      final logMessage = '$timestamp [$_appName] [$levelStr] $tagStr$message';
      
      switch (level) {
        case LogLevel.debug:
          debugPrint(logMessage);
          break;
        case LogLevel.info:
          debugPrint(logMessage);
          break;
        case LogLevel.warning:
          debugPrint(logMessage);
          break;
        case LogLevel.error:
          debugPrint(logMessage);
          break;
      }
    }
  }
}