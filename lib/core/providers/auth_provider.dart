import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user.dart';
import '../../data/models/login_request.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/login_response.dart';
import '../network/api_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _loading = false;
  String? _error;
  final AuthService _authService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final req = LoginRequest(email: email.trim(), password: password);
      final LoginResponse resp = await _authService.login(req);

      // save token securely
      await _storage.write(key: 'auth_token', value: resp.token);
      // save family group id for later APIs
      await _storage.write(key: 'family_group_id', value: resp.familyGroupId);

      // create a simple current user record. The login response doesn't include
      // full profile fields expected by `User`, so fill with sensible defaults.
      _currentUser = User(
        id: resp.userId,
        email: resp.email,
        firstName: '',
        role: 'user',
      );

      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'family_group_id');
    notifyListeners();
  }
}
