import 'package:flutter/material.dart';
import 'app_config.dart';

class ProdConfig implements AppConfig {
  @override
  String get baseUrl => 'https://api.daynight.com'; // Replace with your actual production URL
  
  @override
  String get apiBaseUrl => '$baseUrl/api';
  
  @override
  String get coverImageBaseUrl => '$baseUrl/assets/admin/img/event/cover-image';
  
  @override
  int get defaultLanguageId => 22;
  
  @override
  Color get mainBackgroundColor => const Color(0x0C0E12FF);
  
  @override
  Color get brandPrimary => const Color(0xFF6200EE);
  
  @override
  Color get brandPrimaryInvert => const Color(0x22262F40);
  
  @override
  bool get enableAnalytics => true;
  
  @override
  bool get enableCrashReporting => true;
  
  @override
  Duration get apiTimeout => const Duration(seconds: 10);
  
  @override
  Duration get cacheExpiration => const Duration(hours: 24);
}
