import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../widgets/primary_button.dart';
import 'auth_flow.dart';
import 'home_shell.dart';
import 'verify_email_screen.dart';

/// Decides which screen to show from the authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.initializing) return const _Splash();
    if (!auth.isSignedIn) return const AuthFlow();
    if (!auth.isVerified) return const VerifyEmailScreen();
    if (auth.profile == null) {
      if (auth.profileLoading || auth.busy) return const _Splash();
      return const _ProfileMissing();
    }
    return const HomeShell();
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _ProfileMissing extends StatelessWidget {
  const _ProfileMissing();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We could not load your profile.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Try again', onPressed: auth.retryProfile),
              TextButton(onPressed: auth.logout, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }
}
