import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../models/user.dart';
import '../../models/user_status.dart';
import '../../services/authentication_service.dart';
import '../../utils/logger.dart';

class UserController with ChangeNotifier {
  User? _user;
  UserStatus _status = UserStatus.unknown;
  final AuthenticationService _authService = AuthenticationService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  UserStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get fullName => _user?.fullName;
  String? get thumbnail => _user?.thumbnail;
  String? get address => _user?.address;

  // Status convenience getters
  bool get isLoggedIn => _status == UserStatus.connected && _user != null;
  bool get isGuest => _status == UserStatus.guest;
  bool get isUnknown => _status == UserStatus.unknown;

  /// Initialize the controller by loading stored authentication data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      Logger.info('Initializing UserController', 'UserController');

      // Load stored status and user data
      _status = await _authService.getStoredUserStatus();
      _user = await _authService.getStoredUser();

      Logger.info(
        'Loaded stored status: ${_status.displayName}, has user: ${_user != null}',
        'UserController',
      );

      // If we have a connected status, validate the token
      if (_status == UserStatus.connected) {
        final token = await _authService.getStoredToken();
        if (token != null) {
          Logger.info('Validating stored authentication token', 'UserController');
          final isValid = await _authService.validateToken();
          if (!isValid) {
            Logger.warning(
              'Stored token is invalid, resetting to unknown status',
              'UserController',
            );
            // Clear invalid authentication data
            await _authService.clearStoredData();
            _status = UserStatus.unknown;
            _user = null;
          } else {
            Logger.info('Token validation successful', 'UserController');
            // If we have a valid token but no user data, something went wrong
            if (_user == null) {
              Logger.warning(
                'Valid token but no user data found, resetting authentication',
                'UserController',
              );
              await _authService.clearStoredData();
              _status = UserStatus.unknown;
            }
          }
        } else {
          // No token but connected status - inconsistent state
          Logger.warning(
            'Connected status but no token found, resetting authentication',
            'UserController',
          );
          await _authService.clearStoredData();
          _status = UserStatus.unknown;
          _user = null;
        }
      }

      Logger.info(
        'UserController initialized with final status: ${_status.displayName}',
        'UserController',
      );
    } catch (e) {
      Logger.error('Error initializing UserController: $e', 'UserController');
      _status = UserStatus.unknown;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      Logger.info('Attempting login for: $email', 'UserController');

      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        _status = UserStatus.connected;
        _safeNotifyListeners();
        Logger.info('Login successful', 'UserController');
        return true;
      } else {
        Logger.warning('Login failed', 'UserController');
        return false;
      }
    } catch (e) {
      Logger.error('Login error: $e', 'UserController');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      Logger.info('Attempting Google sign-in', 'UserController');

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Logger.info('Google sign-in cancelled by user', 'UserController');
        return false;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Send the Google token to your backend for verification
      final user = await _authService.loginWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
        email: googleUser.email,
        displayName: googleUser.displayName ?? '',
        photoUrl: googleUser.photoUrl,
      );

      if (user != null) {
        _user = user;
        _status = UserStatus.connected;
        _safeNotifyListeners();
        Logger.info('Google login successful', 'UserController');
        return true;
      } else {
        Logger.warning('Google login failed', 'UserController');
        return false;
      }
    } catch (e) {
      Logger.error('Google login error: $e', 'UserController');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with Apple
  Future<bool> loginWithApple() async {
    _setLoading(true);
    try {
      Logger.info('Attempting Apple sign-in', 'UserController');

      // Sign in with Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Send the Apple credential to your backend for verification
      final user = await _authService.loginWithApple(
        identityToken: credential.identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        fullName: credential.givenName != null && credential.familyName != null
            ? '${credential.givenName} ${credential.familyName}'
            : null,
        userIdentifier: credential.userIdentifier,
      );

      if (user != null) {
        _user = user;
        _status = UserStatus.connected;
        _safeNotifyListeners();
        Logger.info('Apple login successful', 'UserController');
        return true;
      } else {
        Logger.warning('Apple login failed', 'UserController');
        return false;
      }
    } catch (e) {
      Logger.error('Apple login error: $e', 'UserController');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send SMS verification code
  Future<Map<String, dynamic>?> sendOtpCode(String phoneNumber, {String? countryCode}) async {
    _setLoading(true);
    try {
      // Concatenate country code with phone number if provided
      // Remove leading zero from phone number when adding country code

      Logger.info('Sending SMS code to: $phoneNumber', 'UserController');

      final response = await _authService.sendOtpCode(phoneNumber, countryCode ?? '');
      if (response != null) {
        Logger.info('SMS code sent successfully', 'UserController');
        return response;
      } else {
        Logger.warning('Failed to send SMS code', 'UserController');
        return null;
      }
    } catch (e) {
      Logger.error('SMS code sending error: $e', 'UserController');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP code
  Future<Map<String, dynamic>?> verifyOtpCode(String phoneNumber, String otpCode, {String? countryCode}) async {
    _setLoading(true);
    try {
      Logger.info('Verifying OTP code for: $phoneNumber', 'UserController');

      final response = await _authService.verifyOtpCode(phoneNumber, otpCode, countryCode: countryCode ?? '');
      if (response != null) {
        Logger.info('OTP verification successful', 'UserController');
        return response;
      } else {
        Logger.warning('OTP verification failed', 'UserController');
        return null;
      }
    } catch (e) {
      Logger.error('OTP verification error: $e', 'UserController');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Store authentication token for future API calls
  Future<void> storeAuthToken(String token) async {
    try {
      // Store token using the authentication service
      await _authService.storeToken(token);
      Logger.info('Authentication token stored successfully', 'UserController');
    } catch (e) {
      Logger.error('Failed to store authentication token: $e', 'UserController');
    }
  }

  /// Login with SMS verification code
  Future<bool> loginWithSMS(String phoneNumber, String verificationCode) async {
    _setLoading(true);
    try {
      Logger.info('Attempting SMS login for: $phoneNumber', 'UserController');

      final response = await _authService.verifyOtpCode(phoneNumber, verificationCode, countryCode: '');

      if (response != null && response['status'] == 'success') {
        // If the response contains user data, create User object and set status
        if (response['user'] != null) {
          final userData = response['user'] as Map<String, dynamic>;
          _user = User.fromJson(userData);
        } else {
          // For now, create a minimal user object if no user data is returned
          _user = User(
            fullName: 'SMS User',
            email: '',
            phoneNumber: phoneNumber,
            sex: 'unknown',
            thumbnail: null,
            address: null,
          );
        }
        
        _status = UserStatus.connected;
        
        // Store the authentication data persistently
        if (response['token'] != null) {
          await _authService.storeToken(response['token'] as String);
        }
        await _authService.storeUser(_user!);
        await _authService.storeUserStatus(_status);
        
        _safeNotifyListeners();
        Logger.info('SMS login successful', 'UserController');
        return true;
      } else {
        Logger.warning('SMS login failed', 'UserController');
        return false;
      }
    } catch (e) {
      Logger.error('SMS login error: $e', 'UserController');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user
  Future<bool> register({
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
    _setLoading(true);
    try {
      Logger.info('Attempting registration for: $email', 'UserController');

      final user = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        sex: sex,
        dob: dob,
        idNumber: idNumber,
        address: address,
        smsCode: smsCode,
      );

      if (user != null) {
        _user = user;
        _status = UserStatus.connected;
        _safeNotifyListeners();
        Logger.info('Registration successful', 'UserController');
        return true;
      } else {
        Logger.warning('Registration failed', 'UserController');
        return false;
      }
    } catch (e) {
      Logger.error('Registration error: $e', 'UserController');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set user status after successful SMS registration/verification
  Future<void> setUserFromRegistration({
    required String phoneNumber,
    required Map<String, dynamic> registrationData,
  }) async {
    try {
      // Create user object from registration data
      _user = User(
        fullName: registrationData['fullName'] ?? 'SMS User',
        email: registrationData['email'] ?? '',
        phoneNumber: phoneNumber,
        sex: registrationData['sex'] ?? 'unknown',
        thumbnail: null,
        address: registrationData['address'],
      );
      
      _status = UserStatus.connected;
      
      // Store the user data and status persistently
      await _authService.storeUser(_user!);
      await _authService.storeUserStatus(_status);
      
      _safeNotifyListeners();
      Logger.info('User status set to connected after registration', 'UserController');
    } catch (e) {
      Logger.error('Error setting user from registration: $e', 'UserController');
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    _setLoading(true);
    try {
      Logger.info('Logging out user', 'UserController');
      await _authService.logout();
      _user = null;
      _status = UserStatus.unknown;
      _safeNotifyListeners();
    } catch (e) {
      Logger.error('Logout error: $e', 'UserController');
    } finally {
      _setLoading(false);
    }
  }

  /// Continue as guest user
  Future<void> continueAsGuest() async {
    _setLoading(true);
    try {
      Logger.info('Setting user status to guest', 'UserController');
      await _authService.continueAsGuest();
      _user = null;
      _status = UserStatus.guest;
      _safeNotifyListeners();
    } catch (e) {
      Logger.error('Error setting guest status: $e', 'UserController');
    } finally {
      _setLoading(false);
    }
  }

  /// Manually set user (for testing/demo purposes)
  void setUser(User user) {
    _user = user;
    _status = UserStatus.connected;
    _safeNotifyListeners();
  }

  /// Update user status
  void setStatus(UserStatus status) {
    _status = status;
    _safeNotifyListeners();
  }

  /// Safe notification that defers to avoid calling during build
  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Private helper to manage loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Defer notifyListeners to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
