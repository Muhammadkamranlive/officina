import 'package:flutter/material.dart';
import 'package:client/Server/Enums/UserRole.dart';

class RoleSelectionProvider extends ChangeNotifier {
  UserRole? _selectedRole;

  UserRole? get role => _selectedRole;

  void selectRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clear() {
    _selectedRole = null;
    notifyListeners();
  }
}
