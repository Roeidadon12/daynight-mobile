import 'package:flutter/foundation.dart';
import 'app_config.dart';
import 'dev_config.dart';
import 'prod_config.dart';

class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  late final AppConfig config;

  factory ConfigManager() {
    return _instance;
  }

  ConfigManager._internal() {
    // Initialize the appropriate configuration based on the environment
    config = kDebugMode ? DevConfig() : ProdConfig();
  }

  static AppConfig get() => ConfigManager().config;
}
