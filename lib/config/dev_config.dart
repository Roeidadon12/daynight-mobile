import 'package:flutter/material.dart';
import 'app_config.dart';

class DevConfig implements AppConfig {
  /// Primary and fallback URLs
  static const String primaryDomain = 'https://daynight.co.il';
  static const String fallbackIp = 'https://104.21.4.6';
  
  @override
  String get baseUrl => '$primaryDomain/roei-test';
  
  @override
  String get apiBaseUrl => '$baseUrl/api';
  
  @override
  String get coverImageBaseUrl => '$baseUrl/assets/admin/img/event/cover-image';

  @override
  String get organizerImageBaseUrl => '$baseUrl/assets/admin/img/organizer-photo';
  
  @override
  int get defaultLanguageId => 22;
  
  @override
  Color get mainBackgroundColor => const Color(0xFF0C0E12);

  @override
  Color get brandNegativePrimary => const Color(0xFFF97066);

  @override
  Color get brandPrimary => const Color(0xFF6200EE);
  
  @override
  Color get brandPrimaryInvert => const Color(0x22262F40);

  @override
  Color get brandTextPrimary => const Color(0xFFFFFFFF);
  
  @override
  bool get enableAnalytics => false;
  
  @override
  bool get enableCrashReporting => false;
  
  @override
  Duration get apiTimeout => const Duration(seconds: 30);
  
  @override
  Duration get cacheExpiration => const Duration(hours: 1);
}
