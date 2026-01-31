import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/permission_service.dart';

/// Supported locales for voice recognition
enum SupportedLocale {
  englishIndia('en_IN', 'English (India)'),
  hindiIndia('hi_IN', 'Hindi'),
  gujaratiIndia('gu_IN', 'Gujarati');

  final String localeCode;
  final String displayName;

  const SupportedLocale(this.localeCode, this.displayName);
}

class VoiceToTextService {
  static final VoiceToTextService _instance = VoiceToTextService._internal();
  late stt.SpeechToText _speechToText;
  String _recognizedText = '';
  bool _isListening = false;
  String _currentLocale = 'en_IN'; // Default to English (India)

  factory VoiceToTextService() {
    return _instance;
  }

  VoiceToTextService._internal() {
    _speechToText = stt.SpeechToText();
  }

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  String get currentLocale => _currentLocale;

  /// Get list of supported locales
  static List<SupportedLocale> getSupportedLocales() {
    return SupportedLocale.values;
  }

  /// Set the current locale for speech recognition
  void setLocale(SupportedLocale locale) {
    _currentLocale = locale.localeCode;
    debugPrint('Locale set to: ${locale.displayName} ($_currentLocale)');
  }

  /// Set locale by locale code string (e.g., 'en_IN', 'hi_IN', 'gu_IN')
  bool setLocaleByCode(String localeCode) {
    try {
      final supportedCodes = SupportedLocale.values.map((e) => e.localeCode).toList();
      if (!supportedCodes.contains(localeCode)) {
        debugPrint('Unsupported locale: $localeCode');
        return false;
      }
      _currentLocale = localeCode;
      debugPrint('Locale set to: $_currentLocale');
      return true;
    } catch (e) {
      debugPrint('Error setting locale: $e');
      return false;
    }
  }

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

  /// Start listening for speech input with optional locale override
  /// Defaults to currentLocale if not specified
  /// Returns true if listening started successfully
  Future<bool> startListening({
    String? localeId,
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

      // Use provided localeId or default to currentLocale
      final effectiveLocaleId = localeId ?? _currentLocale;

      _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          debugPrint('Recognized [$effectiveLocaleId]: $_recognizedText');
        },
        localeId: effectiveLocaleId,
      );

      debugPrint('Listening started with locale: $effectiveLocaleId');
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
