import 'dart:convert';
import 'package:day_night/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../constants.dart';
import '../models/user.dart';
import '../models/user_status.dart';
import '../utils/logger.dart';
import '../utils/api_headers.dart';

/// Service responsible for managing user authentication, including login,
/// registration, logout, and token management with persistent storage.
class AuthenticationService {
  // ==================== CONSTANTS & FIELDS ====================
  
  final ApiService _api;
  static const String _tokenKey = 'user_token';
  static const String _userKey = 'user_data';
  static const String _statusKey = 'user_status';

  // ==================== CONSTRUCTOR ====================
  
  AuthenticationService()
    : _api = ApiService(
        baseUrl: kLoginBaseUrl,
        timeout: const Duration(seconds: 30),
      );

  // ==================== AUTHENTICATION METHODS ====================

  /// Authenticates a user with email and password
  /// Returns the authenticated user on success, null on failure
  Future<User?> login(String email, String password) async {
    try {
      Logger.info('Attempting login for email: $email', 'AuthService');

      final response = await _api.request(
        endpoint: '/auth/login',
        method: 'POST',
        body: {'email': email, 'password': password},
        headers: await ApiHeaders.buildPublic(),
      );

      return _handleAuthResponse(response, 'Login');
    } catch (e) {
      Logger.error('Login error: $e', 'AuthService');
      return null;
    }
  }

  /// Registers a new user account
  /// Returns the newly created user on success, null on failure
  Future<User?> register({
    required String fullName,
    required String email,
    String? password,
    required String phoneNumber,
    required String sex,
    DateTime? dob,
    String? idNumber,
    String? address,
    String? smsCode,
  }) async {
    try {
      Logger.info('Attempting registration for email: $email', 'AuthService');

      final requestBody = {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'sex': sex,
      };

      if (password != null) requestBody['password'] = password;
      if (dob != null) requestBody['date_of_birth'] = dob.toIso8601String();
      if (idNumber != null) requestBody['id_number'] = idNumber;
      if (address != null) requestBody['address'] = address;
      if (smsCode != null) requestBody['sms_code'] = smsCode;

      final response = await _api.request(
        endpoint: '/auth/register',
        method: 'POST',
        body: requestBody,
        headers: await ApiHeaders.buildPublic(),
      );

      return _handleAuthResponse(response, 'Registration');
    } catch (e) {
      Logger.error('Registration error: $e', 'AuthService');
      return null;
    }
  }

  /// Authenticates a user with Google Sign-In
  /// Returns the authenticated user on success, null on failure
  Future<User?> loginWithGoogle({
    required String? accessToken,
    required String? idToken,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      Logger.info('Attempting Google login for email: $email', 'AuthService');

      final response = await _api.request(
        endpoint: '/auth/google',
        method: 'POST',
        body: {
          'access_token': accessToken,
          'id_token': idToken,
          'email': email,
          'display_name': displayName,
          if (photoUrl != null) 'photo_url': photoUrl,
        },
        headers: await ApiHeaders.buildPublic(),
      );

      return _handleAuthResponse(response, 'Google login');
    } catch (e) {
      Logger.error('Google login error: $e', 'AuthService');
      return null;
    }
  }

  /// Authenticates a user with Apple Sign-In
  /// Returns the authenticated user on success, null on failure
  Future<User?> loginWithApple({
    required String? identityToken,
    required String? authorizationCode,
    required String? email,
    required String? fullName,
    required String? userIdentifier,
  }) async {
    try {
      Logger.info('Attempting Apple login for email: $email', 'AuthService');

      final response = await _api.request(
        endpoint: '/auth/apple',
        method: 'POST',
        body: {
          'identity_token': identityToken,
          'authorization_code': authorizationCode,
          'email': email,
          'full_name': fullName,
          'user_identifier': userIdentifier,
        },
        headers: await ApiHeaders.buildPublic(),
      );

      return _handleAuthResponse(response, 'Apple login');
    } catch (e) {
      Logger.error('Apple login error: $e', 'AuthService');
      return null;
    }
  }

  /// Logs out the current user and clears all stored authentication data
  Future<void> logout() async {
    try {
      Logger.info('Logging out current user', 'AuthService');

      // Try to notify the server about logout (optional, don't fail if it doesn't work)
      try {
        await _api.request(
          endpoint: '/auth/logout', 
          method: 'POST',
          headers: await ApiHeaders.buildHeader(),
        );
      } catch (e) {
        Logger.warning('Server logout notification failed: $e', 'AuthService');
      }

      // Clear local storage
      await clearStoredData();
      Logger.info('Logout completed successfully', 'AuthService');
    } catch (e) {
      Logger.error('Logout error: $e', 'AuthService');
      // Still clear local data even if server notification fails
      await clearStoredData();
    }
  }

  /// Sets the user as guest (no authentication required)
  Future<void> continueAsGuest() async {
    try {
      Logger.info('User choosing to continue as guest', 'AuthService');
      await _storeUserStatus(UserStatus.guest);
      await _clearToken();
      await _clearUser();
    } catch (e) {
      Logger.error('Error setting guest status: $e', 'AuthService');
    }
  }

  // ==================== SMS/OTP METHODS ====================

  /// Send SMS verification code to phone number
  /// Returns the response object on success, null on failure
  Future<Map<String, dynamic>?> sendOtpCode(String phoneNumber, String countryCode) async {
    try {
      Logger.info('Sending SMS code to: $phoneNumber', 'AuthService');
      final fullPhoneNumber = _formatPhoneNumber(phoneNumber, countryCode);

      final response = await _api.postMultipart(
        ApiCommands.getSendOtp.value,
        fields: {'phone': fullPhoneNumber},
        headers: await ApiHeaders.buildMultipartHeaders(null, false),
      );

      return _handleOtpResponse(response, 'SMS code sent successfully', 'Failed to send SMS code');
    } catch (e) {
      Logger.error('SMS code sending error: $e', 'AuthService');
      return null;
    }
  }

  /// Verify OTP code for phone number
  /// Returns the response object on success, null on failure
  Future<Map<String, dynamic>?> verifyOtpCode(String phoneNumber, String otpCode, {String countryCode = ''}) async {
    try {
      Logger.info('Verifying OTP code for: $phoneNumber', 'AuthService');
      final fullPhoneNumber = _formatPhoneNumber(phoneNumber, countryCode);
      
      // Debug: Log the exact data being sent
      Logger.info('Debug - Phone number input: "$phoneNumber"', 'AuthService');
      Logger.info('Debug - Country code: "$countryCode"', 'AuthService');
      Logger.info('Debug - Formatted phone number: "$fullPhoneNumber"', 'AuthService');
      Logger.info('Debug - OTP code: "$otpCode"', 'AuthService');
      Logger.info('Debug - Endpoint: "${ApiCommands.verifyOtp.value}"', 'AuthService');
      Logger.info('Debug - Base URL: "${_api.baseUrl}"', 'AuthService');

      final headers = await ApiHeaders.buildMultipartHeaders(null, false);
      Logger.info('Debug - Headers being sent: $headers', 'AuthService');

      final response = await _api.postMultipart(
        ApiCommands.verifyOtp.value,
        fields: {
          'phone': fullPhoneNumber,
          'otp': otpCode,
        },
        headers: headers,
      );

      return _handleOtpResponse(response, 'OTP verification successful', 'OTP verification failed');
    } catch (e) {
      Logger.error('OTP verification error: $e', 'AuthService');
      return null;
    }
  }

  // ==================== TOKEN & VALIDATION METHODS ====================

  /// Validates the current authentication token with the server
  Future<bool> validateToken() async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        Logger.info('No token found for validation', 'AuthService');
        return false;
      }

      Logger.info('Validating authentication token with server', 'AuthService');
      
      final response = await _api.request(
        endpoint: '/auth/validate',
        method: 'GET',
        headers: await ApiHeaders.buildHeader(),
      );

      final isValid = response['status'] == 'success';
      Logger.info('Token validation result: ${isValid ? "valid" : "invalid"}', 'AuthService');
      
      return isValid;
    } catch (e) {
      Logger.error('Token validation failed: $e', 'AuthService');
      return false;
    }
  }

  // ==================== STORAGE RETRIEVAL METHODS ====================

  /// Retrieves the stored authentication token
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      Logger.info('Retrieved stored token: ${token != null ? "found" : "not found"}', 'AuthService');
      return token;
    } catch (e) {
      Logger.error('Error retrieving stored token: $e', 'AuthService');
      return null;
    }
  }

  /// Retrieves the stored user data
  Future<User?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userData);
        Logger.info('Retrieved stored user: ${user.email.isNotEmpty ? user.email : user.phoneNumber}', 'AuthService');
        return user;
      }
      Logger.info('No stored user data found', 'AuthService');
      return null;
    } catch (e) {
      Logger.error('Error retrieving stored user: $e', 'AuthService');
      return null;
    }
  }

  /// Retrieves the stored user status
  Future<UserStatus> getStoredUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusString = prefs.getString(_statusKey);
      if (statusString != null) {
        return UserStatus.values.firstWhere(
          (status) => status.name == statusString,
          orElse: () => UserStatus.unknown,
        );
      }
      return UserStatus.unknown;
    } catch (e) {
      Logger.error('Error retrieving stored user status: $e', 'AuthService');
      return UserStatus.unknown;
    }
  }

  // ==================== STORAGE MANAGEMENT METHODS ====================

  /// Clears all stored authentication data
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userKey),
      prefs.remove(_statusKey),
    ]);
    Logger.info('All stored authentication data cleared', 'AuthService');
  }

  /// Store authentication token for future API calls
  Future<void> storeToken(String token) async {
    await _storeToken(token);
  }

  /// Public method to store user data
  Future<void> storeUser(User user) async {
    await _storeUser(user);
  }

  /// Public method to store user status
  Future<void> storeUserStatus(UserStatus status) async {
    await _storeUserStatus(status);
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Common handler for authentication responses
  Future<User?> _handleAuthResponse(Map<String, dynamic> response, String operation) async {
    if (response['status'] == 'success' &&
        response['token'] != null &&
        response['user'] != null) {
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      // Store authentication data
      await _storeToken(token);
      await _storeUserStatus(UserStatus.connected);

      final user = User.fromJson(userData);
      await _storeUser(user);

      Logger.info('$operation successful for user: ${user.email}', 'AuthService');
      return user;
    } else {
      Logger.warning('$operation failed: Invalid response format', 'AuthService');
      return null;
    }
  }

  /// Common handler for OTP responses
  Map<String, dynamic>? _handleOtpResponse(Map<String, dynamic> response, String successMsg, String failureMsg) {
    if (response['status'] == 'success') {
      Logger.info(successMsg, 'AuthService');
      return response;
    } else {
      Logger.warning('$failureMsg: ${response['message']}', 'AuthService');
      return null;
    }
  }

  /// Format phone number with country code
  String _formatPhoneNumber(String phoneNumber, String countryCode) {
    // If phone number already includes country code (starts with +), use as-is
    if (phoneNumber.startsWith('+')) {
      // But ensure no leading zero after country code
      final parts = phoneNumber.split('0');
      if (parts.length > 1 && phoneNumber.contains('+9720')) {
        // Israeli number with incorrect format +9720XXXXXXXX -> +972XXXXXXXX
        return phoneNumber.replaceFirst('+9720', '+972');
      }
      return phoneNumber;
    }
    
    // For local numbers, remove leading zero and add country code
    final cleanPhoneNumber = phoneNumber.startsWith('0') 
        ? phoneNumber.substring(1) 
        : phoneNumber;
    return countryCode + cleanPhoneNumber;
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    Logger.info('Authentication token stored successfully', 'AuthService');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    Logger.info('Authentication token cleared', 'AuthService');
  }

  Future<void> _storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    Logger.info('User data stored successfully for: ${user.email.isNotEmpty ? user.email : user.phoneNumber}', 'AuthService');
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    Logger.info('User data cleared', 'AuthService');
  }

  Future<void> _storeUserStatus(UserStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, status.name);
    Logger.info('User status stored: ${status.displayName} with key: "$_statusKey" and value: "${status.name}"', 'AuthService');
    
    // Debug: Verify it was stored
    final verification = prefs.getString(_statusKey);
    Logger.info('Verification - stored status retrieved: "$verification"', 'AuthService');
  }
}
