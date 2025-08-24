import 'package:flutter/material.dart';
import 'config/config_manager.dart';

// Access configuration values through ConfigManager
final config = ConfigManager.get();

// API URLs
String get kBaseUrl => config.baseUrl;
String get kApiBaseUrl => config.apiBaseUrl;
String get kCoverImageBaseUrl => config.coverImageBaseUrl;
int kAppLanguageId = config.defaultLanguageId; // Can be updated at runtime

// Colors
Color get kMainBackgroundColor => config.mainBackgroundColor;
Color get kBrandPrimary => config.brandPrimary;
Color get kBrandPrimaryInvert => config.brandPrimaryInvert;

// Assets
const kDefaultEventImage = 'assets/images/image_place_holder.png';