import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_helpers.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/error_banner.dart';
import '../widgets/password_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onRegister});

  final VoidCallback onRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().login(_email.text, _password.text);
  }

  Future<void> _forgotPassword() async {
    final error = Validators.aluEmail(_email.text);
    if (error != null) {
      showSnack(context, 'Enter your ALU email above first', error: true);
      return;
    }
    final ok = await context.read<AuthProvider>().resetPassword(_email.text);
    if (!mounted) return;
    showSnack(
      context,
      ok ? 'Password reset email sent' : 'Could not send reset email',
      error: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to report and track campus issues.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.aluEmail,
              decoration: const InputDecoration(
                labelText: 'ALU email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            PasswordField(
              controller: _password,
              validator: (v) => Validators.required(v, 'Password'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot password?'),
              ),
            ),
            if (auth.error != null) ...[
              ErrorBanner(auth.error!),
              const SizedBox(height: 12),
            ],
            PrimaryButton(label: 'Sign in', onPressed: _submit, loading: auth.busy),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('New here?'),
                TextButton(
                  onPressed: widget.onRegister,
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
