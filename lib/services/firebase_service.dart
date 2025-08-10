import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/models/submission_model.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseFunctions? _functions;

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
      if (_isInitialized) {
        print('Firebase already initialized');
        return;
      }

      print('Initializing Firebase...');
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

      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _functions = FirebaseFunctions.instance;

      _isInitialized = true;
      print('Firebase initialized successfully');
      print('Firestore instance: ${_firestore != null}');
      print('Auth instance: ${_auth != null}');
    } catch (e) {
      print('Error initializing Firebase: $e');
      _isInitialized = false;
      // Don't rethrow for now, allow app to continue with mock services
    }
  }

  // Ensure Firebase is initialized
  static Future<bool> ensureInitialized() async {
    if (!_isInitialized) {
      print('Firebase not initialized, attempting to initialize...');
      await initializeFirebase();
    }
    return _isInitialized;
  }

  // Debug method to test basic Firebase connectivity
  static Future<void> testFirebaseConnection() async {
    try {
      print('🧪 Testing Firebase connection...');

      if (!_isInitialized) {
        print('🧪 Firebase not initialized');
        return;
      }

      // Test basic collection access
      final testSnapshot = await _firestore!.collection('forms').limit(1).get();
      print('🧪 Test query successful: ${testSnapshot.docs.length} docs found');

      // Test current user
      final user = FirebaseAuth.instance.currentUser;
      print('🧪 Current user: ${user?.uid ?? 'null'}');
    } catch (e) {
      print('🧪 Firebase connection test failed: $e');
    }
  }

  // Debug method to get all forms without user filtering
  static Future<List<FormModel>> getAllFormsDebug() async {
    try {
      print('🧪 Getting all forms for debug...');

      if (_firestore == null) {
        print('🧪 Firestore not initialized');
        return [];
      }

      final snapshot = await _firestore!.collection('forms').get();
      print('🧪 Found ${snapshot.docs.length} total forms in database');

      final forms = snapshot.docs
          .map((doc) {
            try {
              final form = FormModel.fromMap(doc.data(), doc.id);
              print(
                  '🧪 Form: ${form.title} (${form.id}) - Created by: ${form.createdBy}');
              return form;
            } catch (e) {
              print('🧪 Error parsing form ${doc.id}: $e');
              return null;
            }
          })
          .where((form) => form != null)
          .cast<FormModel>()
          .toList();

      print('🧪 Successfully parsed ${forms.length} forms');
      return forms;
    } catch (e) {
      print('🧪 Error getting all forms: $e');
      return [];
    }
  }

  // Debug method to check authentication state
  static Future<void> checkAuthState() async {
    try {
      print('🔐 Checking Firebase Auth state...');

      if (_auth == null) {
        print('🔐 Firebase Auth not initialized');
        return;
      }

      final user = _auth!.currentUser;
      if (user != null) {
        print('🔐 User is authenticated:');
        print('🔐   UID: ${user.uid}');
        print('🔐   Email: ${user.email}');
        print('🔐   Display Name: ${user.displayName}');
        print('🔐   Is Anonymous: ${user.isAnonymous}');
        print('🔐   Email Verified: ${user.emailVerified}');
        print('🔐   Creation Time: ${user.metadata.creationTime}');
        print('🔐   Last Sign In: ${user.metadata.lastSignInTime}');
      } else {
        print('🔐 No user is currently authenticated');
      }

      // Check auth state changes
      _auth!.authStateChanges().listen((User? user) {
        print('🔐 Auth state changed: ${user?.uid ?? 'null'}');
      });
    } catch (e) {
      print('🔐 Error checking auth state: $e');
    }
  }

  // Method to get forms with orderBy (requires composite index)
  static Stream<List<FormModel>> getFormsStreamWithOrderBy() {
    print('🔍 getFormsStreamWithOrderBy: Starting...');

    if (_firestore == null) {
      print('🔍 getFormsStreamWithOrderBy: Firestore not initialized');
      return Stream.value([]);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('🔍 getFormsStreamWithOrderBy: No current user found');
        return Stream.value([]);
      }

      print(
          '🔍 getFormsStreamWithOrderBy: Querying forms for user: ${user.uid}');

      // This query requires a composite index on (createdBy, updatedAt)
      return _firestore!
          .collection('forms')
          .where('createdBy', isEqualTo: user.uid)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        print(
            '🔍 getFormsStreamWithOrderBy: Snapshot received with ${snapshot.docs.length} docs');

        final forms = snapshot.docs
            .map((doc) {
              try {
                return FormModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                print(
                    '🔍 getFormsStreamWithOrderBy: Error parsing form ${doc.id}: $e');
                return null;
              }
            })
            .where((form) => form != null)
            .cast<FormModel>()
            .toList();

        print(
            '🔍 getFormsStreamWithOrderBy: Successfully parsed ${forms.length} forms');
        return forms;
      }).handleError((error) {
        print('🔍 getFormsStreamWithOrderBy: Error - Index required: $error');
        print(
            '🔍 getFormsStreamWithOrderBy: Create index at: https://console.firebase.google.com/v1/r/project/formflow-b0484/firestore/indexes');
        return <FormModel>[];
      });
    } catch (e) {
      print('🔍 getFormsStreamWithOrderBy: Exception: $e');
      return Stream.value([]);
    }
  }

  // Helper method to get the index creation URL
  static String getIndexCreationUrl() {
    return 'https://console.firebase.google.com/v1/r/project/formflow-b0484/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9mb3JtZmxvdy1iMDQ4NC9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvZm9ybXMvaW5kZXhlcy9fEAEaDQoJY3JlYXRlZEJ5EAEaDQoJdXBkYXRlZEF0EAIaDAoIX19uYW1lX18QAg';
  }

  // Firestore instance
  static FirebaseFirestore? get firestore {
    if (!_isInitialized) {
      print('Warning: Firebase not initialized. Using mock service.');
      return null;
    }
    return _firestore;
  }

  // Auth instance
  static FirebaseAuth? get auth {
    if (!_isInitialized) {
      print('Warning: Firebase not initialized. Using mock service.');
      return null;
    }
    return _auth;
  }

  // Functions instance
  static FirebaseFunctions? get functions {
    if (!_isInitialized) {
      print('Warning: Firebase not initialized. Using mock service.');
      return null;
    }
    return _functions;
  }

  // Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;

  // Form operations
  static Future<String> createForm(FormModel form) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    final docRef = await _firestore!.collection('forms').add({
      ...form.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  static Future<void> updateForm(String formId, FormModel form) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    await _firestore!.collection('forms').doc(formId).update({
      ...form.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> publishForm(String formId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      // Generate share link
      final shareLink = 'https://formflow-b0484.web.app/form/$formId';

      // Update form status to active and add share link
      await _firestore!.collection('forms').doc(formId).update({
        'status': 'active',
        'shareLink': shareLink,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error publishing form: $e');
      rethrow;
    }
  }

  // Get forms stream for the current user
  static Stream<List<FormModel>> getFormsStream() {
    print('🔍 getFormsStream: Starting...');
    print('🔍 getFormsStream: Firebase initialized: $_isInitialized');
    print('🔍 getFormsStream: Firestore instance: ${_firestore != null}');

    if (_firestore == null) {
      print(
          '🔍 getFormsStream: Firestore not initialized, returning empty stream');
      return Stream.value([]);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('🔍 getFormsStream: No current user found');
        return Stream.value([]);
      }

      print('🔍 getFormsStream: Querying forms for user: ${user.uid}');

      // Use a simpler query that doesn't require complex indexing
      // First try to get forms with basic filtering
      return _firestore!
          .collection('forms')
          .where('createdBy', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        print(
            '🔍 getFormsStream: Snapshot received with ${snapshot.docs.length} docs');

        final forms = snapshot.docs
            .map((doc) {
              try {
                return FormModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                print('🔍 getFormsStream: Error parsing form ${doc.id}: $e');
                print('🔍 getFormsStream: Form data: ${doc.data()}');
                return null;
              }
            })
            .where((form) => form != null)
            .cast<FormModel>()
            .toList();

        // Sort forms locally instead of using orderBy in the query
        forms.sort((a, b) {
          final aTime = a.updatedAt ?? DateTime(1900);
          final bTime = b.updatedAt ?? DateTime(1900);
          return bTime.compareTo(aTime); // Most recent first
        });

        print('🔍 getFormsStream: Successfully parsed ${forms.length} forms');
        print(
            '🔍 getFormsStream: Form titles: ${forms.map((f) => '${f.title}(${f.id})').join(', ')}');
        return forms;
      }).handleError((error) {
        print('🔍 getFormsStream: Error in stream: $error');
        // Return empty list on error instead of trying complex fallback
        return <FormModel>[];
      });
    } catch (e) {
      print('🔍 getFormsStream: Exception in stream creation: $e');
      return Stream.value([]);
    }
  }

  // Debug method to get forms stream without user filtering
  static Stream<List<FormModel>> getFormsStreamDebug() {
    print('🔍 getFormsStreamDebug: Starting...');
    print('🔍 getFormsStreamDebug: Firebase initialized: $_isInitialized');
    print('🔍 getFormsStreamDebug: Firestore instance: ${_firestore != null}');

    if (_firestore == null) {
      print(
          '🔍 getFormsStreamDebug: Firestore not initialized, returning empty stream');
      return Stream.value([]);
    }

    try {
      print('🔍 getFormsStreamDebug: Querying all forms without user filter');

      return _firestore!
          .collection('forms')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .handleError((error) {
        print('🔍 getFormsStreamDebug: Error in stream: $error');
        return <FormModel>[];
      }).map((snapshot) {
        print(
            '🔍 getFormsStreamDebug: Snapshot received with ${snapshot.docs.length} docs');

        final forms = snapshot.docs
            .map((doc) {
              try {
                final form = FormModel.fromMap(doc.data(), doc.id);
                print(
                    '🔍 getFormsStreamDebug: Form: ${form.title} (${form.id}) - Created by: ${form.createdBy}');
                return form;
              } catch (e) {
                print(
                    '🔍 getFormsStreamDebug: Error parsing form ${doc.id}: $e');
                print('🔍 getFormsStreamDebug: Form data: ${doc.data()}');
                return null;
              }
            })
            .where((form) => form != null)
            .cast<FormModel>()
            .toList();

        print(
            '🔍 getFormsStreamDebug: Successfully parsed ${forms.length} forms');
        return forms;
      });
    } catch (e) {
      print('🔍 getFormsStreamDebug: Exception in stream creation: $e');
      return Stream.value([]);
    }
  }

  static Future<List<FormModel>> getForms() async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    final snapshot = await _firestore!
        .collection('forms')
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FormModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get a specific form by ID
  static Future<FormModel?> getForm(String formId) async {
    if (_firestore == null) return null;

    try {
      final doc = await _firestore!.collection('forms').doc(formId).get();
      if (doc.exists) {
        return FormModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting form: $e');
      return null;
    }
  }

  static Future<void> deleteForm(String formId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    await _firestore!.collection('forms').doc(formId).delete();
  }

  // Get current user
  static User? get currentUser => _auth?.currentUser;

  // Sign in anonymously for demo purposes
  static Future<UserCredential> signInAnonymously() async {
    if (_auth == null) throw Exception('Auth not initialized');
    return await _auth!.signInAnonymously();
  }

  // Submission operations
  static Future<String> createSubmission(SubmissionModel submission) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    final docRef = await _firestore!.collection('submissions').add({
      ...submission.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  static Future<List<SubmissionModel>> getSubmissionsForForm(
      String formId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    final snapshot = await _firestore!
        .collection('submissions')
        .where('formId', isEqualTo: formId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  static Future<void> updateSubmissionStatus(
      String submissionId, String status) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    await _firestore!.collection('submissions').doc(submissionId).update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': currentUser?.uid,
    });
  }

  static Future<void> deleteSubmission(String submissionId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    await _firestore!.collection('submissions').doc(submissionId).delete();
  }

  static Stream<List<SubmissionModel>> getSubmissionsStream(String formId) {
    if (_firestore == null) throw Exception('Firestore not initialized');

    return _firestore!
        .collection('submissions')
        .where('formId', isEqualTo: formId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
