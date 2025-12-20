import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      
      // If we have a connected status but no user, validate the token
      if (_status == UserStatus.connected && _user != null) {
        final isValid = await _authService.validateToken();
        if (!isValid) {
          Logger.warning('Stored token is invalid, logging out', 'UserController');
          await logout();
        }
      }
      
      Logger.info('UserController initialized with status: ${_status.displayName}', 'UserController');
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
        notifyListeners();
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
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
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
        notifyListeners();
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

  /// Register a new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String sex,
    required DateTime dob,
    required String idNumber,
    String? address,
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
      );
      
      if (user != null) {
        _user = user;
        _status = UserStatus.connected;
        notifyListeners();
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

  /// Logout the current user
  Future<void> logout() async {
    _setLoading(true);
    try {
      Logger.info('Logging out user', 'UserController');
      await _authService.logout();
      _user = null;
      _status = UserStatus.unknown;
      notifyListeners();
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
      notifyListeners();
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
    notifyListeners();
  }

  /// Update user status
  void setStatus(UserStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Private helper to manage loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
