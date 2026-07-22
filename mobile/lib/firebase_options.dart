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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB83nM-yLtp8NU29ixG-3wuAt5BXMwa5VY',
    authDomain: 'tunebox-25.firebaseapp.com',
    projectId: 'tunebox-25',
    storageBucket: 'tunebox-25.firebasestorage.app',
    messagingSenderId: '18325106102',
    appId: '1:18325106102:web:5088df9781cccef12c2517',
    measurementId: 'G-Q0MYVDYJ3K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB83nM-yLtp8NU29ixG-3wuAt5BXMwa5VY',
    authDomain: 'tunebox-25.firebaseapp.com',
    projectId: 'tunebox-25',
    storageBucket: 'tunebox-25.firebasestorage.app',
    messagingSenderId: '18325106102',
    appId: '1:18325106102:android:PLACEHOLDER',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_IOS_API_KEY',
    authDomain: 'tunebox-25.firebaseapp.com',
    projectId: 'tunebox-25',
    storageBucket: 'tunebox-25.firebasestorage.app',
    messagingSenderId: '18325106102',
    appId: '1:18325106102:ios:PLACEHOLDER',
    iosBundleId: 'com.tunebox.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER_MACOS_API_KEY',
    authDomain: 'tunebox-25.firebaseapp.com',
    projectId: 'tunebox-25',
    storageBucket: 'tunebox-25.firebasestorage.app',
    messagingSenderId: '18325106102',
    appId: '1:18325106102:macos:PLACEHOLDER',
    iosBundleId: 'com.tunebox.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB83nM-yLtp8NU29ixG-3wuAt5BXMwa5VY',
    authDomain: 'tunebox-25.firebaseapp.com',
    projectId: 'tunebox-25',
    storageBucket: 'tunebox-25.firebasestorage.app',
    messagingSenderId: '18325106102',
    appId: '1:18325106102:web:5088df9781cccef12c2517',
    measurementId: 'G-Q0MYVDYJ3K',
  );
}
