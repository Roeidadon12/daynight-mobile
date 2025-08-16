import 'dart:ffi';

import 'package:flutter/material.dart';
import '../../../models/user.dart';

class UserController with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  String? get fullName => _user?.fullName;
  String? get thumbnail => _user?.thumbnail;
  String? get address => _user?.address;
  bool get isLoggedIn => _user != null;
}
