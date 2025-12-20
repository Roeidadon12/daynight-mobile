/// Enumeration representing the different connection/authentication states 
/// that a user can have in the DayNight application.
///
/// This enum is used throughout the app to determine what features 
/// and functionality should be available to the user.
enum UserStatus {
  /// User is authenticated and logged in with full access to features
  connected,
  
  /// User is using the app without authentication (limited access)
  guest,
  
  /// Initial state or when authentication status is being determined
  unknown;

  /// Returns a human-readable string representation of the status
  String get displayName {
    switch (this) {
      case UserStatus.connected:
        return 'Connected';
      case UserStatus.guest:
        return 'Guest';
      case UserStatus.unknown:
        return 'Unknown';
    }
  }

  /// Returns true if the user has full authentication privileges
  bool get isAuthenticated => this == UserStatus.connected;

  /// Returns true if the user is in guest mode
  bool get isGuest => this == UserStatus.guest;

  /// Returns true if the status is still being determined
  bool get isUnknown => this == UserStatus.unknown;
}