import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../mock/mock_users.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _loading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    // Simulate a short delay as if checking credentials
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final match = mockUsers.firstWhere(
        (u) => (u['email'] as String).toLowerCase() == email.toLowerCase() && (u['password'] as String) == password,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        _currentUser = User(
          id: match['id'] as String,
          email: match['email'] as String,
          firstName: (match['name'] as String),
          role: match['role'] as String,
        );
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid credentials';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
