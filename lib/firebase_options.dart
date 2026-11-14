import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Run flutterfire configure for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7-syxJTZo3Gvu7OZt4WjzwPtUntK4kG0',
    appId: '1:1098853569366:android:c32fd0f68da592eae0bcf7',
    messagingSenderId: '1098853569366',
    projectId: 'campus-incident-app-8c019',
    storageBucket: 'campus-incident-app-8c019.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCugUHoOVr84Mpz7_OvaAqLufrLT6JaVHM',
    appId: '1:1098853569366:ios:e1d035b6c3136c41e0bcf7',
    messagingSenderId: '1098853569366',
    projectId: 'campus-incident-app-8c019',
    storageBucket: 'campus-incident-app-8c019.firebasestorage.app',
    iosClientId: '1098853569366-3f709datd9abda8alrgn5vj9v2tllnis.apps.googleusercontent.com',
    iosBundleId: 'com.danielntwali.campusIncidentApp',
  );
}
