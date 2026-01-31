import 'package:flutter/material.dart';

class PasscodeLoginPage extends StatefulWidget {
  const PasscodeLoginPage({super.key});

  @override
  State<PasscodeLoginPage> createState() => _PasscodeLoginPageState();
}

class _PasscodeLoginPageState extends State<PasscodeLoginPage> {
  final _passcodeCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passcodeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final passcode = _passcodeCtrl.text.trim();
    if (passcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter passcode')));
      return;
    }
    Navigator.of(context).pop(passcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Passcode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enter your passcode to continue', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                TextField(
                  controller: _passcodeCtrl,
                  obscureText: _obscure,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Passcode',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _submit, child: const Text('Unlock')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
