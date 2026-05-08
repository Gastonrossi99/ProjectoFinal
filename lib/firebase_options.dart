import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASpurSnrEHJxfETrov3ikVguSS46XtsPM',
    appId: '1:493172181811:web:ed83d30dbfb9aa628b8c46',
    messagingSenderId: '493172181811',
    projectId: 'ianime-2a36d',
    authDomain: 'ianime-2a36d.firebaseapp.com',
    storageBucket: 'ianime-2a36d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_API_KEY_ANDROID', // Opcional si usas google-services.json
    appId: 'TU_APP_ID_ANDROID',
    messagingSenderId: 'TU_SENDER_ID_AQUI',
    projectId: 'TU_PROJECT_ID_AQUI',
    storageBucket: 'TU_STORAGE_BUCKET_AQUI',
  );
}
