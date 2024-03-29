// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBL8Fui1v91CAkv99lX6pOleM24o0jZCkE',
    appId: '1:860600295218:web:e9535ff18bda6d5721012b',
    messagingSenderId: '860600295218',
    projectId: 'noted-cc64a',
    authDomain: 'noted-cc64a.firebaseapp.com',
    databaseURL: 'https://noted-cc64a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'noted-cc64a.appspot.com',
    measurementId: 'G-T9EV5VZNRQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAspnrYVnIhyKxv8OL0JBAJdcQ7XUGcrPI',
    appId: '1:860600295218:android:9af87b767993561221012b',
    messagingSenderId: '860600295218',
    projectId: 'noted-cc64a',
    databaseURL: 'https://noted-cc64a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'noted-cc64a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDV-ZdyNEF9CCv2cTgTc6bC-IItPfcbLvM',
    appId: '1:860600295218:ios:86cb05e06fa09aa521012b',
    messagingSenderId: '860600295218',
    projectId: 'noted-cc64a',
    databaseURL: 'https://noted-cc64a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'noted-cc64a.appspot.com',
    iosBundleId: 'com.example.noted',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDV-ZdyNEF9CCv2cTgTc6bC-IItPfcbLvM',
    appId: '1:860600295218:ios:10004d3a61a32c0921012b',
    messagingSenderId: '860600295218',
    projectId: 'noted-cc64a',
    databaseURL: 'https://noted-cc64a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'noted-cc64a.appspot.com',
    iosBundleId: 'com.example.noted.RunnerTests',
  );
}
