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
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Don't rethrow for now, allow app to continue with mock services
    }
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

  static Stream<List<FormModel>> getFormsStream() {
    if (_firestore == null) throw Exception('Firestore not initialized');

    return _firestore!
        .collection('forms')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FormModel.fromMap(doc.data(), doc.id))
            .toList());
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

  static Future<FormModel?> getForm(String formId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    final doc = await _firestore!.collection('forms').doc(formId).get();
    if (doc.exists) {
      return FormModel.fromMap(doc.data()!, doc.id);
    }
    return null;
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
