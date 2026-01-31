import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/services/passcode_service.dart';
import 'passcode_login_page.dart';
import 'set_passcode_page.dart';
// dashboard route is registered via named routes in main.dart

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPasscodeLogin = false;

  @override
  void initState() {
    super.initState();
    _checkPasscodeOption();
  }

  Future<void> _checkPasscodeOption() async {
    final hasPasscode = await PasscodeService().hasPasscode();
    if (mounted && hasPasscode) {
      setState(() => _showPasscodeLogin = true);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasscodeLogin(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final passcode = await navigator.push<String>(
      MaterialPageRoute(builder: (ctx) => const PasscodeLoginPage()),
    );
    if (passcode == null || passcode.isEmpty) return;

    final service = PasscodeService();
    try {
      final verified = await service.verifyPasscode(passcode);
      if (!verified) {
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Incorrect passcode')));
        return;
      }
      // Passcode verified, navigate to dashboard
      if (!mounted) return;
      navigator.pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;

    if (success) {
      // Check if user needs to set a passcode
      final hasPasscode = await PasscodeService().hasPasscode();
      if (!hasPasscode) {
        // Show optional passcode setup
        await navigator.push<bool>(
          MaterialPageRoute(builder: (ctx) => const SetPasscodePage()),
        );
        if (!mounted) return;
        navigator.pushReplacementNamed('/dashboard');
      } else {
        navigator.pushReplacementNamed('/dashboard');
      }
    } else {
      final err = auth.error ?? 'Login failed';
      messenger.showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // If passcode login is available, show that UI
    if (_showPasscodeLogin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unlock with passcode')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 48, color: Colors.amber),
                        const SizedBox(height: 16),
                        const Text('Enter your passcode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.fingerprint),
                            onPressed: () => _handlePasscodeLogin(context),
                            label: const Text('Unlock'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _showPasscodeLogin = false),
                          child: const Text('Use email & password instead'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Standard email/password login
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !auth.loading,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          enabled: !auth.loading,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.login),
                            onPressed: auth.loading ? null : () => _submit(context),
                            label: auth.loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            // Continue as guest: navigate to dashboard without auth
                            Navigator.of(context).pushReplacementNamed('/dashboard');
                          },
                          child: const Text('Continue as guest'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
