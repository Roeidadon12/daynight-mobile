import 'package:flutter/material.dart';
import 'config/config_manager.dart';

// Access configuration values through ConfigManager
final config = ConfigManager.get();

// API URLs
String get kBaseUrl => config.baseUrl;
String get kApiBaseUrl => config.apiBaseUrl;
String get kApiStorePath => config.apiStorePath;
String get kLoginBaseUrl => config.loginBaseUrl;
String get kCoverImageBaseUrl => config.coverImageBaseUrl;
String get kOrganizerImageBaseUrl => config.organizerImageBaseUrl;
int kAppLanguageId = config.defaultLanguageId; // Can be updated at runtime

// Authentication
String get kAppToken => config.appToken; // Bearer token for API requests

// Debug Settings
bool get kEnableDebugCurlOutput => config.enableDebugCurlOutput;

// Colors
Color get kMainBackgroundColor => config.mainBackgroundColor;
Color get kBrandPrimary => config.brandPrimary;
Color get kBrandNegativePrimary => config.brandNegativePrimary;
Color get kBrandPrimaryInvert => config.brandPrimaryInvert;
Color get kBrandTextPrimary => config.brandTextPrimary;

// Assets
const kDefaultEventImage = 'assets/images/image_place_holder.png';

// Validation Regex
const kPhoneValidationRegex = r'^05[0-9][0-9]{7}$';
