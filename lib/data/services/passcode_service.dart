import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/passcode_model.dart';

class PasscodeService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _passcodeKey = 'user_passcode';

  /// Set a new passcode
  Future<void> setPasscode(String passcode) async {
    final model = PasscodeModel(passcode: passcode, createdAt: DateTime.now());
    await _storage.write(key: _passcodeKey, value: model.toJson().toString());
  }

  /// Get stored passcode or null if not set
  Future<String?> getPasscode() async {
    try {
      final stored = await _storage.read(key: _passcodeKey);
      return stored;
    } catch (_) {
      return null;
    }
  }

  /// Check if passcode is set
  Future<bool> hasPasscode() async {
    final passcode = await getPasscode();
    return passcode != null && passcode.isNotEmpty;
  }

  /// Verify passcode matches
  Future<bool> verifyPasscode(String input) async {
    final stored = await getPasscode();
    return stored == input;
  }

  /// Clear/delete passcode
  Future<void> clearPasscode() async {
    await _storage.delete(key: _passcodeKey);
  }
}
