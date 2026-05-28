import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android; // Default to Android config
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDMw3LxDGy3wknc6Krc2BoHw8VHMgW0_c',
    appId: '1:288012292455:android:ece88e907e1d2b5c419fc2',
    messagingSenderId: '288012292455',
    projectId: 'appflutter-e47ab',
    storageBucket: 'appflutter-e47ab.firebasestorage.app',
    databaseURL: 'https://appflutter-e47ab-default-rtdb.firebaseio.com',
  );
}
