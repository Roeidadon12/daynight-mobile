import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

/// Utility class for building standardized API headers across the entire application
class ApiHeaders {
  static const String _tokenKey = 'user_token';

  /// Builds standard headers with optional Bearer token and custom headers
  /// 
  /// Returns headers with:
  /// - Accept: application/json
  /// - x-api-key: App token from constants
  /// - Content-Type: application/json
  /// - Authorization: Bearer {token} (if token exists in storage and useBearer is true)
  /// - Any custom headers (will override defaults if same key)
  /// 
  /// [useBearer] - Whether to include Bearer token in headers (default: true)
  /// [customHeaders] - Optional custom headers to add/override defaults
  static Future<Map<String, String>> buildHeader([Map<String, String>? customHeaders, bool useBearer = true]) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'x-api-key': kAppToken,
      'Content-Type': 'application/json',
    };

    // Add Bearer token if available and useBearer is true
    if (useBearer) {
      final token = await _getStoredToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    // Add any custom headers (will override defaults if same key)
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Builds headers without authentication token
  /// Useful for public endpoints or when token is not required
  static Future<Map<String, String>> buildPublic([Map<String, String>? customHeaders]) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'x-api-key': kAppToken,
      'Content-Type': 'application/json',
    };

    // Add any custom headers (will override defaults if same key)
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Retrieves the stored authentication token
  static Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Gets current stored token (for external use if needed)
  static Future<String?> getCurrentToken() async {
    return await _getStoredToken();
  }
}