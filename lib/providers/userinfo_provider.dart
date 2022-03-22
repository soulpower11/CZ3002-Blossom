import 'package:flutter/material.dart';

class UserInfoProvider with ChangeNotifier {
  String _username = "";
  String _email = "";

  String get username => _username;
  String get email => _email;

  void setUsername(String name) {
    _username = name;
    // notifyListeners();
  }

  void setEmail(String mail) {
    _email = mail;
    // notifyListeners();
  }
}
