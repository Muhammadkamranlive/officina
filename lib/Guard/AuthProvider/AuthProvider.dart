import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/UserRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();

  AppUser? _appUser;
  bool _isLoading = true;

  AppUser? get user => _appUser;
  bool get isAuthenticated => _appUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      _appUser = await _userRepo.getByUid(firebaseUser.uid);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setUser(AppUser user) {
    _appUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _appUser = null;
    notifyListeners();
  }
}