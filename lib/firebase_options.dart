// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYvvTWnq5dkA9s09fN9-bEMeE51zev3kI',
    appId: '1:120394588076:web:c918b11f84b7b554ae6409',
    messagingSenderId: '120394588076',
    projectId: 'final-project-25937',
    authDomain: 'final-project-25937.firebaseapp.com',
    storageBucket: 'final-project-25937.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsid0tn9kCGjWY4J0yczdHJ4NRnPYDGt0',
    appId: '1:120394588076:android:dd0ee1d2639c309cae6409',
    messagingSenderId: '120394588076',
    projectId: 'final-project-25937',
    storageBucket: 'final-project-25937.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCydmoO8uv_Nx7XXdX5Swad-A14NNRL5kY',
    appId: '1:120394588076:ios:1eec0fc323f83a22ae6409',
    messagingSenderId: '120394588076',
    projectId: 'final-project-25937',
    storageBucket: 'final-project-25937.firebasestorage.app',
    iosBundleId: 'com.example.finalproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCydmoO8uv_Nx7XXdX5Swad-A14NNRL5kY',
    appId: '1:120394588076:ios:1eec0fc323f83a22ae6409',
    messagingSenderId: '120394588076',
    projectId: 'final-project-25937',
    storageBucket: 'final-project-25937.firebasestorage.app',
    iosBundleId: 'com.example.finalproject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBYvvTWnq5dkA9s09fN9-bEMeE51zev3kI',
    appId: '1:120394588076:web:7511f32be3a1548dae6409',
    messagingSenderId: '120394588076',
    projectId: 'final-project-25937',
    authDomain: 'final-project-25937.firebaseapp.com',
    storageBucket: 'final-project-25937.firebasestorage.app',
  );

}