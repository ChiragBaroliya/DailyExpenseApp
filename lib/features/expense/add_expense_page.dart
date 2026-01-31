import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/expense_provider.dart';
import '../../data/models/expense_request.dart';
import '../../data/services/voice_to_text_service.dart';
import '../../data/services/voice_expense_parser.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _voiceService = VoiceToTextService();

  String _category = 'Food';
  String _paymentMode = 'Cash';
  DateTime _date = DateTime.now();
  bool _isListening = false;
  int _listeningDot = 0;

  final List<String> _categories = [
    'Food',
    'Groceries',
    'Transport',
    'Subscription',
    'Utilities',
    'Entertainment',
    'Health',
    'Shopping',
    'Other',
  ];

  final List<String> _paymentModes = [
    'Cash',
    'Card',
    'UPI',
    'Bank Transfer',
    'Wallet',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _showListeningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Voice Input'),
        content: SizedBox(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: AlwaysStoppedAnimation(_listeningDot),
                builder: (ctx, child) {
                  return Text(
                    'Listening${'.' * ((_listeningDot % 4) + 1)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    _voiceService.cancelListening();
                    setState(() => _isListening = false);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice input cancelled')),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Animate listening dots
    _animateListeningDots();
  }

  void _animateListeningDots() {
    if (!_isListening) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isListening) {
        setState(() => _listeningDot++);
        _animateListeningDots();
      }
    });
  }

  Future<void> _startVoiceInput() async {
    try {
      final initialized = await _voiceService.initialize();
      if (!initialized) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
        return;
      }

      setState(() => _isListening = true);
      final success = await _voiceService.startListening();
      if (!success) {
        setState(() => _isListening = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start listening')),
        );
        return;
      }

      // Show listening dialog and start timeout
      if (!mounted) return;
      _showListeningDialog();
      
      // Timeout after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (_isListening && mounted) {
          _voiceService.cancelListening();
          setState(() => _isListening = false);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listening timeout - no speech detected')),
          );
        }
      });
    } catch (e) {
      setState(() => _isListening = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _stopVoiceInput() async {
    try {
      final recognizedText = await _voiceService.stopListening();
      setState(() => _isListening = false);
      
      // Close listening dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (recognizedText.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No speech recognized. Please try again.')),
        );
        return;
      }
      
      // Parse voice input using VoiceExpenseParser
      final parsed = VoiceExpenseParser.parseVoiceExpense(recognizedText);
      
      // Autofill form fields
      if (parsed['amount'] != null) {
        _amountController.text = parsed['amount'].toString();
      }
      
      // Update category if valid
      if (parsed['category'] != null && 
          _categories.contains(parsed['category'])) {
        setState(() => _category = parsed['category']);
      }
      
      // Update payment mode if valid
      if (parsed['paymentMode'] != null && 
          _paymentModes.contains(parsed['paymentMode'])) {
        setState(() => _paymentMode = parsed['paymentMode']);
      }
      
      // Append notes
      if (parsed['notes'] != null && 
          (parsed['notes'] as String).isNotEmpty) {
        final currentNotes = _notesController.text.trim();
        final newNotes = currentNotes.isEmpty 
          ? parsed['notes'] 
          : '$currentNotes ${parsed['notes']}';
        _notesController.text = newNotes;
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input parsed and autofilled'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isListening = false);
      
      // Close listening dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final notes = _notesController.text.trim();

    final userId = context.read<AuthProvider>().currentUser?.id ?? 'admin_1';

    final req = ExpenseRequest(
      amount: amount,
      category: _category,
      paymentMode: _paymentMode,
      date: _date.toUtc().toIso8601String(),
      notes: notes.isNotEmpty ? notes : null,
      createdBy: userId,
      familyGroupId: 'family_1',
    );

    try {
      await context.read<ExpenseProvider>().addExpense(req);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add expense: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter amount';
                        final val = double.tryParse(v.replaceAll(',', ''));
                        if (val == null || val <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v ?? _category),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _paymentMode,
                      items: _paymentModes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _paymentMode = v ?? _paymentMode),
                      decoration: const InputDecoration(labelText: 'Payment mode'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text('Date: ${_date.toLocal()}'.split(' ')[0])),
                        TextButton(onPressed: _pickDate, child: const Text('Pick')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                          child: Column(
                            children: [
                              FloatingActionButton.small(
                                onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
                                backgroundColor: _isListening ? Colors.orange : Colors.blue,
                                tooltip: _isListening ? 'Stop listening' : 'Start voice input',
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: _save,
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
