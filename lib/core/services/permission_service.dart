import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request microphone permission for voice input
  /// Returns true if permission is granted, false otherwise
  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Check if microphone permission is already granted
  static Future<bool> hasMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Open app settings to allow user to grant permissions manually
  static Future<void> openPermissionSettings() async {
    try {
      openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }
}
