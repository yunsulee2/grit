import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final String email;
  final String? profileImageUrl;

  const UserProfile({
    required this.name,
    required this.email,
    this.profileImageUrl,
  });
}

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _isLoggedIn = false;
  UserProfile? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  UserProfile? get currentUser => _currentUser;

  static const _mockUser = UserProfile(
    name: '김운동',
    email: 'workout@gmail.com',
  );

  Future<void> loginWithKakao() async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _currentUser = _mockUser;
    notifyListeners();
  }

  Future<void> loginWithNaver() async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _currentUser = _mockUser;
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _currentUser = _mockUser;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
