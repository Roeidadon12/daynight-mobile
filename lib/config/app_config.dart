import 'package:flutter/material.dart';

abstract class AppConfig {
  // API Configuration
  String get baseUrl;
  String get apiBaseUrl;
  String get apiStorePath;
  String get loginBaseUrl;
  String get coverImageBaseUrl;
  String get organizerImageBaseUrl;
  
  // Authentication
  String get appToken; // Bearer token for API requests
  
  // Default Settings
  int get defaultLanguageId;
  
  // Theme Configuration
  Color get mainBackgroundColor;
  Color get brandNegativePrimary;
  Color get brandPrimary;
  Color get brandPrimaryInvert;
  Color get brandTextPrimary;
  
  // Feature Flags
  bool get enableAnalytics;
  bool get enableCrashReporting;
  bool get enableDebugCurlOutput;
  
  // Timeouts
  Duration get apiTimeout;
  Duration get cacheExpiration;
}
