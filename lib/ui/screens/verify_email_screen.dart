import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _poll;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Quietly check every few seconds so the user is let in automatically.
    _poll = Timer.periodic(const Duration(seconds: 4), (_) {
      context.read<AuthProvider>().checkVerified();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final verified = await context.read<AuthProvider>().checkVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (!verified) {
      showSnack(context, 'Email not verified yet. Open the link we sent you.', error: true);
    }
  }

  Future<void> _resend() async {
    final ok = await context.read<AuthProvider>().resendVerification();
    if (!mounted) return;
    showSnack(
      context,
      ok ? 'Verification email sent' : 'Please wait before requesting another email',
      error: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Verify your email',
      subtitle: 'We sent a verification link to ${auth.user?.email ?? 'your email'}. '
          'Open it, then come back here.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.mark_email_unread_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Check your spam folder if you cannot find the email.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'I have verified my email',
            onPressed: _check,
            loading: _checking,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _resend, child: const Text('Resend verification email')),
          TextButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            child: const Text('Use a different account'),
          ),
        ],
      ),
    );
  }
}
