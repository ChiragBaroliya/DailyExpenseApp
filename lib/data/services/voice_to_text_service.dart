import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/permission_service.dart';

class VoiceToTextService {
  static final VoiceToTextService _instance = VoiceToTextService._internal();
  late stt.SpeechToText _speechToText;
  String _recognizedText = '';
  bool _isListening = false;

  factory VoiceToTextService() {
    return _instance;
  }

  VoiceToTextService._internal() {
    _speechToText = stt.SpeechToText();
  }

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  /// Initialize the speech recognizer
  /// Returns true if initialization is successful, false otherwise
  Future<bool> initialize() async {
    try {
      // Request microphone permission first
      final hasPermission = await PermissionService.requestMicrophonePermission();
      if (!hasPermission) {
        debugPrint('Microphone permission denied');
        return false;
      }

      final available = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
        },
      );
      return available;
    } catch (e) {
      debugPrint('Failed to initialize speech recognizer: $e');
      return false;
    }
  }

  /// Start listening for speech input
  /// Returns true if listening started successfully
  Future<bool> startListening({
    String localeId = 'en_US',
  }) async {
    try {
      if (!_speechToText.isAvailable) {
        debugPrint('Speech recognition not available on this device');
        return false;
      }

      if (_isListening) {
        debugPrint('Already listening');
        return false;
      }

      _recognizedText = '';
      _isListening = true;

      _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          debugPrint('Recognized: $_recognizedText');
        },
        localeId: localeId,
      );

      return true;
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      return false;
    }
  }

  /// Stop listening and return the recognized text
  /// Returns the recognized text as a String
  Future<String> stopListening() async {
    try {
      if (!_isListening) {
        return _recognizedText;
      }

      await _speechToText.stop();
      _isListening = false;
      return _recognizedText;
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
      _isListening = false;
      return _recognizedText;
    }
  }

  /// Cancel listening without returning text
  Future<void> cancelListening() async {
    try {
      if (_isListening) {
        await _speechToText.cancel();
        _recognizedText = '';
        _isListening = false;
      }
    } catch (e) {
      debugPrint('Error cancelling speech recognition: $e');
      _isListening = false;
    }
  }

  /// Dispose of the speech recognizer
  void dispose() {
    _speechToText.stop();
    _isListening = false;
    _recognizedText = '';
  }
}
