import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _isInitialized = false;

  // Firebase configuration
  static const Map<String, dynamic> firebaseConfig = {
    "apiKey": "AIzaSyBlPlYZKa2jtYb2uNEKHNexpk07IFSRJuo",
    "authDomain": "formflow-b0484.firebaseapp.com",
    "projectId": "formflow-b0484",
    "storageBucket": "formflow-b0484.firebasestorage.app",
    "messagingSenderId": "951373712327",
    "appId": "1:951373712327:web:45c7f78e3ed2b783f9a7e2",
    "measurementId": "G-BG0G0MHPGG"
  };

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBlPlYZKa2jtYb2uNEKHNexpk07IFSRJuo",
          authDomain: "formflow-b0484.firebaseapp.com",
          projectId: "formflow-b0484",
          storageBucket: "formflow-b0484.firebasestorage.app",
          messagingSenderId: "951373712327",
          appId: "1:951373712327:web:45c7f78e3ed2b783f9a7e2",
          measurementId: "G-BG0G0MHPGG",
        ),
      );

      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Don't rethrow for now, allow app to continue with mock services
    }
  }

  // Mock Firestore instance (will be replaced with real implementation)
  static dynamic get firestore {
    if (!_isInitialized) {
      print('Warning: Firebase not initialized. Using mock service.');
      return null;
    }
    // TODO: Return real Firestore instance when packages are installed
    return null;
  }

  // Mock Auth instance (will be replaced with real implementation)
  static dynamic get auth {
    if (!_isInitialized) {
      print('Warning: Firebase not initialized. Using mock service.');
      return null;
    }
    // TODO: Return real Auth instance when packages are installed
    return null;
  }

  // Mock Functions instance (will be replaced with real implementation)
  static dynamic get functions {
    if (!_isInitialized) {
      print('Warning: Firebase not initialized. Using mock service.');
      return null;
    }
    // TODO: Return real Functions instance when packages are installed
    return null;
  }

  // Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;
}
