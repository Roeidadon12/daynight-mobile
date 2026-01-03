import 'package:flutter/material.dart';
import 'app_config.dart';

class ProdConfig implements AppConfig {
  @override
  String get baseUrl => 'https://api.daynight.com'; // Replace with your actual production URL
  
  @override
  String get apiBaseUrl => '$baseUrl/api';
  
  @override
  String get loginBaseUrl => '$baseUrl/api';

  @override
  String get coverImageBaseUrl => '$baseUrl/assets/admin/img/event/cover-image';
  
  @override
  String get organizerImageBaseUrl => '$baseUrl/assets/admin/img/organizer-photo';

  @override
  String get appToken => '05cf2bd6f78994ea4f71ed6a073643cd328c85c9f50423b655e1e01444e08bc7'; // Production app token
  
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
  bool get enableAnalytics => true;
  
  @override
  bool get enableCrashReporting => true;
  
  @override
  Duration get apiTimeout => const Duration(seconds: 10);
  
  @override
  Duration get cacheExpiration => const Duration(hours: 24);
}
