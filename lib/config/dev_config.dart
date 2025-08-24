import 'package:flutter/material.dart';
import 'app_config.dart';

class DevConfig implements AppConfig {
  @override
  String get baseUrl => 'http://10.0.2.2:8001';
  
  @override
  String get apiBaseUrl => '$baseUrl/api';
  
  @override
  String get coverImageBaseUrl => '$baseUrl/assets/admin/img/event/cover-image';
  
  @override
  int get defaultLanguageId => 22;
  
  @override
  Color get mainBackgroundColor => Colors.blueAccent; // Color(0x0C0E12FF);
  
  @override
  Color get brandPrimary => const Color(0xFF6200EE);
  
  @override
  Color get brandPrimaryInvert => const Color(0x22262F40);
  
  @override
  bool get enableAnalytics => false;
  
  @override
  bool get enableCrashReporting => false;
  
  @override
  Duration get apiTimeout => const Duration(seconds: 30);
  
  @override
  Duration get cacheExpiration => const Duration(hours: 1);
}
