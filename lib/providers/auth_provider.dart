import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/services/auth_service.dart';

/// Holds authentication state: the Firebase user, the Firestore profile
/// (with the role) and loading or error flags for the UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _sub = _service.authChanges.listen(_onAuthChanged);
  }

  final AuthService _service;
  StreamSubscription<User?>? _sub;

  User? _user;
  AppUser? _profile;
  bool _initializing = true;
  bool _busy = false;
  bool _profileLoading = false;
  String? _error;

  User? get user => _user;
  AppUser? get profile => _profile;
  bool get initializing => _initializing;
  bool get busy => _busy;
  bool get profileLoading => _profileLoading;
  String? get error => _error;
  bool get isSignedIn => _user != null;
  bool get isVerified => _service.currentUser?.emailVerified ?? false;
  bool get isStaff => _profile?.isStaff ?? false;

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user == null) {
      _profile = null;
      _initializing = false;
      notifyListeners();
      return;
    }
    await _loadProfile();
    _initializing = false;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final uid = _service.currentUser?.uid;
    if (uid == null) return;
    _profileLoading = true;
    notifyListeners();
    try {
      _profile = await _service.fetchProfile(uid);
    } catch (_) {
      _error = 'Could not load your profile. Check your connection.';
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryProfile() => _loadProfile();

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? department,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _service.register(
        name: name,
        email: email,
        password: password,
        department: department,
      );
      await _loadProfile();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendly(e);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _service.login(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendly(e);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }

  Future<bool> resendVerification() async {
    try {
      await _service.sendVerificationEmail();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendly(e);
      notifyListeners();
      return false;
    }
  }

  /// Returns true when the email is now verified.
  Future<bool> checkVerified() async {
    try {
      await _service.reloadUser();
    } catch (_) {
      return false;
    }
    notifyListeners();
    return isVerified;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _service.resetPassword(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendly(e);
      notifyListeners();
      return false;
    }
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and retry.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
