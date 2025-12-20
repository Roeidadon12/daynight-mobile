import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../constants.dart';
import '../models/user.dart';
import '../models/user_status.dart';
import '../utils/logger.dart';

/// Service responsible for managing user authentication, including login,
/// registration, logout, and token management with persistent storage.
class AuthenticationService {
  final ApiService _api;
  static const String _tokenKey = 'user_token';
  static const String _userKey = 'user_data';
  static const String _statusKey = 'user_status';

  AuthenticationService()
    : _api = ApiService(
        baseUrl: kApiBaseUrl,
        timeout: const Duration(seconds: 30),
      );

  /// Authenticates a user with email and password
  /// Returns the authenticated user on success, null on failure
  Future<User?> login(String email, String password) async {
    try {
      Logger.info('Attempting login for email: $email', 'AuthService');

      final response = await _api.request(
        endpoint: '/auth/login',
        method: 'POST',
        body: {'email': email, 'password': password},
      );

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

        Logger.info('Login successful for user: ${user.email}', 'AuthService');
        return user;
      } else {
        Logger.warning('Login failed: Invalid response format', 'AuthService');
        return null;
      }
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
      );

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

        Logger.info(
          'Registration successful for user: ${user.email}',
          'AuthService',
        );
        return user;
      } else {
        Logger.warning(
          'Registration failed: Invalid response format',
          'AuthService',
        );
        return null;
      }
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
      );

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

        Logger.info(
          'Google login successful for user: ${user.email}',
          'AuthService',
        );
        return user;
      } else {
        Logger.warning(
          'Google login failed: Invalid response format',
          'AuthService',
        );
        return null;
      }
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
      );

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

        Logger.info(
          'Apple login successful for user: ${user.email}',
          'AuthService',
        );
        return user;
      } else {
        Logger.warning(
          'Apple login failed: Invalid response format',
          'AuthService',
        );
        return null;
      }
    } catch (e) {
      Logger.error('Apple login error: $e', 'AuthService');
      return null;
    }
  }

  /// Send SMS verification code to phone number
  /// Returns true on success, false on failure
  Future<bool> sendSMSCode(String phoneNumber) async {
    try {
      Logger.info('Sending SMS code to: $phoneNumber', 'AuthService');

      final response = await _api.request(
        endpoint: '/auth/sms/send',
        method: 'POST',
        body: {'phone_number': phoneNumber},
      );

      if (response['status'] == 'success') {
        Logger.info(
          'SMS code sent successfully to: $phoneNumber',
          'AuthService',
        );
        return true;
      } else {
        Logger.warning(
          'Failed to send SMS code: ${response['message']}',
          'AuthService',
        );
        return false;
      }
    } catch (e) {
      Logger.error('SMS code sending error: $e', 'AuthService');
      return false;
    }
  }

  /// Authenticates a user with SMS verification code
  /// Returns the authenticated user on success, null on failure
  Future<User?> loginWithSMS({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    try {
      Logger.info('Attempting SMS login for: $phoneNumber', 'AuthService');

      final response = await _api.request(
        endpoint: '/auth/sms/verify',
        method: 'POST',
        body: {
          'phone_number': phoneNumber,
          'verification_code': verificationCode,
        },
      );

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

        Logger.info(
          'SMS login successful for user: ${user.email}',
          'AuthService',
        );
        return user;
      } else {
        Logger.warning(
          'SMS login failed: Invalid response format',
          'AuthService',
        );
        return null;
      }
    } catch (e) {
      Logger.error('SMS login error: $e', 'AuthService');
      return null;
    }
  }

  /// Logs out the current user and clears all stored authentication data
  Future<void> logout() async {
    try {
      Logger.info('Logging out current user', 'AuthService');

      // Try to notify the server about logout (optional, don't fail if it doesn't work)
      try {
        await _api.request(endpoint: '/auth/logout', method: 'POST');
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

  /// Retrieves the stored authentication token
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
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
        return User.fromJson(userData);
      }
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

  /// Validates the current authentication token with the server
  Future<bool> validateToken() async {
    try {
      final token = await getStoredToken();
      if (token == null) return false;

      final response = await _api.request(
        endpoint: '/auth/validate',
        method: 'GET',
      );

      return response['status'] == 'success';
    } catch (e) {
      Logger.error('Token validation failed: $e', 'AuthService');
      return false;
    }
  }

  /// Clears all stored authentication data
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userKey),
      prefs.remove(_statusKey),
    ]);
  }

  // Private helper methods

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> _storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> _storeUserStatus(UserStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, status.name);
  }
}
