import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Switches between login and register without pushing routes, so the
/// AuthGate can replace everything cleanly once the user signs in.
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool _showRegister = false;

  void _toggle() {
    context.read<AuthProvider>().clearError();
    setState(() => _showRegister = !_showRegister);
  }

  @override
  Widget build(BuildContext context) {
    return _showRegister
        ? RegisterScreen(onLogin: _toggle)
        : LoginScreen(onRegister: _toggle);
  }
}
