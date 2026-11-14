import 'constants.dart';

class Validators {
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? minLength(String? value, int min, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    if (value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  static String? aluEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[\w.+\-]+@([\w\-]+\.)+[a-z]{2,}$');
    if (!pattern.hasMatch(email)) return 'Enter a valid email address';
    final domain = email.split('@').last;
    if (!AppConstants.allowedEmailDomains.contains(domain)) {
      return 'Use your ALU email (${AppConstants.allowedEmailDomains.join(' or ')})';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'\d').hasMatch(value)) return 'Include at least one number';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
