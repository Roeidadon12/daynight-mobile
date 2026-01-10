import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user/user_controller.dart';
import '../models/user_status.dart';
import '../models/user.dart';

/// A provider that wraps UserController and provides global access 
/// to user status throughout the application.
/// 
/// This provider should be placed at the root of the app widget tree
/// to ensure all widgets can access user status information.
class UserStatusProvider extends ChangeNotifierProvider<UserController> {
  UserStatusProvider({super.key, super.child}) 
      : super(
          create: (context) => UserController(),
        );

  /// Convenience method to get UserController from context
  static UserController of(BuildContext context, {bool listen = true}) {
    return Provider.of<UserController>(context, listen: listen);
  }

  /// Convenience method to get user status from context
  static UserStatus statusOf(BuildContext context, {bool listen = true}) {
    return Provider.of<UserController>(context, listen: listen).status;
  }

  /// Convenience method to get user from context
  static User? userOf(BuildContext context, {bool listen = true}) {
    return Provider.of<UserController>(context, listen: listen).user;
  }

  /// Convenience method to check if user is logged in
  static bool isLoggedInOf(BuildContext context, {bool listen = true}) {
    return Provider.of<UserController>(context, listen: listen).isLoggedIn;
  }

  /// Convenience method to check if user is guest
  static bool isGuestOf(BuildContext context, {bool listen = true}) {
    return Provider.of<UserController>(context, listen: listen).isGuest;
  }

  /// Convenience method to check if status is unknown
  static bool isUnknownOf(BuildContext context, {bool listen = true}) {
    return Provider.of<UserController>(context, listen: listen).isUnknown;
  }

  /// Convenience method to check if loading
  static bool isLoadingOf(BuildContext context, {bool listen = true}) {
    return Provider.of<UserController>(context, listen: listen).isLoading;
  }
}

/// A widget that rebuilds based on user authentication status.
/// 
/// This is useful for showing different UI based on whether the user
/// is connected, guest, or unknown.
class UserStatusBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, UserStatus status, User? user) builder;

  const UserStatusBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, _) {
        return builder(context, controller.status, controller.user);
      },
    );
  }
}

/// A widget that shows different content based on user status
class UserStatusSwitch extends StatelessWidget {
  final Widget? connectedWidget;
  final Widget? guestWidget;
  final Widget? unknownWidget;
  final Widget? loadingWidget;

  const UserStatusSwitch({
    super.key,
    this.connectedWidget,
    this.guestWidget,
    this.unknownWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return loadingWidget ?? const CircularProgressIndicator();
        }

        switch (controller.status) {
          case UserStatus.connected:
            return connectedWidget ?? const SizedBox.shrink();
          case UserStatus.guest:
            return guestWidget ?? const SizedBox.shrink();
          case UserStatus.unknown:
            return unknownWidget ?? const SizedBox.shrink();
        }
      },
    );
  }
}