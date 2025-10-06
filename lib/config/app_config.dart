import 'package:flutter/material.dart';

abstract class AppConfig {
  // API Configuration
  String get baseUrl;
  String get apiBaseUrl;
  String get coverImageBaseUrl;
  String get organizerImageBaseUrl;
  
  // Default Settings
  int get defaultLanguageId;
  
  // Theme Configuration
  Color get mainBackgroundColor;
  Color get brandNegativePrimary;
  Color get brandPrimary;
  Color get brandPrimaryInvert;
  
  // Feature Flags
  bool get enableAnalytics;
  bool get enableCrashReporting;
  
  // Timeouts
  Duration get apiTimeout;
  Duration get cacheExpiration;
}
