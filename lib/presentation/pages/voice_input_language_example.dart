import 'package:flutter/material.dart';
import '../../data/services/voice_to_text_service.dart';

/// Example implementation showing how to use VoiceToTextService with multi-language support
class VoiceInputLanguageExample extends StatefulWidget {
  const VoiceInputLanguageExample({super.key});

  @override
  State<VoiceInputLanguageExample> createState() => _VoiceInputLanguageExampleState();
}

class _VoiceInputLanguageExampleState extends State<VoiceInputLanguageExample> {
  final _voiceService = VoiceToTextService();
  
  SupportedLocale _selectedLocale = SupportedLocale.englishIndia;
  String _recognizedText = '';
  bool _isListening = false;
  String _statusMessage = 'Ready to listen';

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    try {
      final initialized = await _voiceService.initialize();
      if (initialized) {
        // Set default locale
        _voiceService.setLocale(SupportedLocale.englishIndia);
        setState(() => _statusMessage = 'Voice service ready');
      } else {
        setState(() => _statusMessage = 'Failed to initialize voice service');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  Future<void> _startListening() async {
    try {
      // Set the selected language before listening
      _voiceService.setLocale(_selectedLocale);
      
      setState(() {
        _isListening = true;
        _statusMessage = 'Listening in ${_selectedLocale.displayName}...';
        _recognizedText = '';
      });

      // Start listening with the selected locale
      final success = await _voiceService.startListening();
      
      if (!success) {
        setState(() {
          _isListening = false;
          _statusMessage = 'Failed to start listening';
        });
      }
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _stopListening() async {
    try {
      final text = await _voiceService.stopListening();
      
      setState(() {
        _isListening = false;
        _recognizedText = text;
        _statusMessage = text.isEmpty 
          ? 'No speech recognized' 
          : 'Recognized: $text';
      });
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _cancelListening() async {
    try {
      await _voiceService.cancelListening();
      setState(() {
        _isListening = false;
        _statusMessage = 'Listening cancelled';
        _recognizedText = '';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Input Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Language',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...VoiceToTextService.getSupportedLocales().map((locale) {
                      final isSelected = _selectedLocale == locale;
                      return InkWell(
                        onTap: _isListening
                            ? null
                            : () {
                                setState(() => _selectedLocale = locale);
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      locale.displayName,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      locale.localeCode,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_isListening)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          height: 20,
                          child: LinearProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Voice Control Buttons
            if (!_isListening)
              FilledButton.icon(
                icon: const Icon(Icons.mic),
                onPressed: _startListening,
                label: const Text('Start Listening'),
              )
            else
              Column(
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.stop),
                    onPressed: _stopListening,
                    label: const Text('Stop Listening'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelListening,
                    label: const Text('Cancel'),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Recognized Text Card
            if (_recognizedText.isNotEmpty)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recognized Text',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _recognizedText,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.content_copy),
                              onPressed: () {
                                // Copy to clipboard
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied to clipboard')),
                                );
                              },
                              label: const Text('Copy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _recognizedText = '');
                              },
                              label: const Text('Clear'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Info Section
            const SizedBox(height: 20),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Use',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Select your desired language\n'
                      '2. Click "Start Listening"\n'
                      '3. Speak clearly into the microphone\n'
                      '4. Click "Stop Listening" to finish\n'
                      '5. See the recognized text below',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current Locale: ${_voiceService.currentLocale}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
