import 'package:flutter/material.dart';
import '../../data/services/passcode_service.dart';

class ModifyPasscodePage extends StatefulWidget {
  const ModifyPasscodePage({super.key});

  @override
  State<ModifyPasscodePage> createState() => _ModifyPasscodePageState();
}

class _ModifyPasscodePageState extends State<ModifyPasscodePage> {
  final _currentCtrl = TextEditingController();
  final _newPasscodeCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _obscure3 = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newPasscodeCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text.trim();
    final newPasscode = _newPasscodeCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPasscode.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }
    if (newPasscode != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passcodes do not match')));
      return;
    }
    if (newPasscode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passcode must be at least 4 characters')));
      return;
    }

    setState(() => _loading = true);
    final service = PasscodeService();
    try {
      final verified = await service.verifyPasscode(current);
      if (!verified) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current passcode is incorrect')));
        return;
      }
      await service.setPasscode(newPasscode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passcode updated')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update passcode: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modify Passcode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Update your passcode', style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _currentCtrl,
                    obscureText: _obscure1,
                    keyboardType: TextInputType.visiblePassword,
                    enabled: !_loading,
                    decoration: InputDecoration(
                      labelText: 'Current Passcode',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasscodeCtrl,
                    obscureText: _obscure2,
                    keyboardType: TextInputType.visiblePassword,
                    enabled: !_loading,
                    decoration: InputDecoration(
                      labelText: 'New Passcode',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: _obscure3,
                    keyboardType: TextInputType.visiblePassword,
                    enabled: !_loading,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Passcode',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure3 ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure3 = !_obscure3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update Passcode'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
