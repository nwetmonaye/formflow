import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/models/submission_model.dart';
import 'dart:convert'; // Added for jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // Added for http.post
import 'package:formflow/models/notification_model.dart'; // Added for NotificationModel

class FirebaseService {
  static bool _isInitialized = false;
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseFunctions? _functions;

  // Set this to false to use production Firebase services instead of emulators
  static const bool _useEmulators = false;

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

      // Configure emulators based on the flag
      if (_useEmulators &&
          const bool.fromEnvironment('dart.vm.product') == false &&
          !const bool.fromEnvironment('dart.library.html')) {
        print('🔧 Configuring Firebase emulators for local development...');

        // Connect to local Firestore emulator
        _firestore!.useFirestoreEmulator('127.0.0.1', 8080);
        print('🔧 Firestore emulator configured: 127.0.0.1:8080');

        // Connect to local Functions emulator
        _functions!.useFunctionsEmulator('127.0.0.1', 5001);
        print('🔧 Functions emulator configured: 127.0.0.1:5001');

        // Connect to local Auth emulator (optional)
        // _auth!.useAuthEmulator('127.0.0.1', 9099);
        // print('🔧 Auth emulator configured: 127.0.0.1:9099');
      } else {
        print('🔧 Using production Firebase services');
      }

      _isInitialized = true;
      print('Firebase initialized successfully');
      print('Firestore instance: ${_firestore != null}');
      print('Auth instance: ${_auth != null}');
      print('Functions instance: ${_functions != null}');

      // Migrate existing forms to include isPublic field
      try {
        await migrateFormsToIncludeIsPublic();
      } catch (e) {
        print('⚠️ Warning: Could not migrate forms: $e');
        // Don't fail initialization if migration fails
      }
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

  // Method to switch between emulator and production
  static void switchToEmulators() {
    if (_firestore != null && _functions != null) {
      print('🔧 Switching to Firebase emulators...');
      _firestore!.useFirestoreEmulator('127.0.0.1', 8080);
      _functions!.useFunctionsEmulator('127.0.0.1', 5001);
      print('🔧 Switched to emulators successfully');
    }
  }

  // Method to switch back to production
  static void switchToProduction() {
    print('🔧 Switching to production Firebase services...');
    // Reinitialize Firebase to use production services
    _isInitialized = false;
    initializeFirebase();
  }

  // Form operations
  static Future<String> createForm(FormModel form) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    print('🔍 createForm: Creating new form');
    print('🔍 createForm: Form email field: ${form.emailField}');
    print('🔍 createForm: Form data to save: ${form.toMap()}');

    final docRef = await _firestore!.collection('forms').add({
      ...form.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('🔍 createForm: Form created with ID: ${docRef.id}');
    return docRef.id;
  }

  static Future<void> updateForm(String formId, FormModel form) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    print('🔍 updateForm: Updating form $formId');
    print('🔍 updateForm: Form email field: ${form.emailField}');
    print('🔍 updateForm: Form data to save: ${form.toMap()}');

    await _firestore!.collection('forms').doc(formId).update({
      ...form.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('🔍 updateForm: Form updated successfully');
  }

  static Future<void> publishForm(String formId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      // Generate share link
      final shareLink = 'https://formflow-b0484.web.app/form/$formId';

      // Get the current form to preserve its settings
      final currentForm = await getForm(formId);
      if (currentForm == null) {
        throw Exception('Form not found');
      }

      // Update form status to active and add share link, preserving isPublic setting
      await _firestore!.collection('forms').doc(formId).update({
        'status': 'active',
        'shareLink': shareLink,
        'isPublic': currentForm.isPublic, // Ensure isPublic field is set
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
      print('🔍 getForm: Loading form $formId');
      final doc = await _firestore!.collection('forms').doc(formId).get();
      if (doc.exists) {
        print('🔍 getForm: Form document exists');
        print('🔍 getForm: Form data from Firebase: ${doc.data()}');
        final form = FormModel.fromMap(doc.data()!, doc.id);
        print('🔍 getForm: Parsed form email field: ${form.emailField}');
        return form;
      }
      print('🔍 getForm: Form document does not exist');
      return null;
    } catch (e) {
      print('🔍 getForm: Error getting form: $e');
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

  // Email operations - now using HTTP endpoint
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String html,
    required String type,
    String? formTitle,
    String? submitterName,
    String? submitterEmail,
    String? status,
    String? comments,
  }) async {
    try {
      print('🔍 Sending email to: $to');
      print('🔍 Email type: $type');
      print('🔍 Email subject: $subject');

      // Use HTTP function directly - no authentication required
      final url =
          'https://us-central1-formflow-b0484.cloudfunctions.net/sendEmailHttp';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'html': html,
          'type': type,
          'formTitle': formTitle,
          'submitterName': submitterName,
          'submitterEmail': submitterEmail,
          'status': status,
          'comments': comments,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] == true;

        if (success) {
          print('✅ Email sent successfully to: $to');
        } else {
          print('❌ Email failed to send to: $to');
          print('❌ Error details: ${data['message'] ?? 'Unknown error'}');
        }

        return success;
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      print('❌ Email details: to=$to, type=$type, subject=$subject');
      return false;
    }
  }

  // Test Firestore connectivity and permissions
  static Future<bool> testFirestoreConnection() async {
    if (_firestore == null) {
      print('🔍 Firestore not initialized');
      return false;
    }

    try {
      print('🔍 Testing Firestore connection...');

      // Try to read a document to test basic connectivity
      final testDoc = await _firestore!.collection('forms').limit(1).get();
      print(
          '🔍 Firestore read test successful: ${testDoc.docs.length} documents');

      // Try to write a test document to test write permissions
      // Use a more specific collection name and avoid potential conflicts
      final testWriteRef =
          await _firestore!.collection('_test_connection').add({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'testId': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      print('🔍 Firestore write test successful: ${testWriteRef.id}');

      // Clean up test document
      await testWriteRef.delete();
      print('🔍 Firestore delete test successful');

      return true;
    } catch (e) {
      print('🔍 Firestore connection test failed: $e');
      print('🔍 Error type: ${e.runtimeType}');

      // If the test collection write fails, try a different approach
      try {
        print('🔍 Trying alternative connection test...');

        // Just test reading from forms collection
        final testDoc = await _firestore!.collection('forms').limit(1).get();
        print(
            '🔍 Alternative read test successful: ${testDoc.docs.length} documents');

        // If we can read, assume basic connectivity is working
        return true;
      } catch (e2) {
        print('🔍 Alternative connection test also failed: $e2');
        return false;
      }
    }
  }

  // Submission operations
  static Future<String> createSubmission(SubmissionModel submission) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    print('🔍 Creating submission in Firebase: ${submission.toMap()}');
    print('🔍 Firestore instance: ${_firestore != null}');
    print('🔍 Current user: ${currentUser?.uid}');
    print('🔍 Submission formId: ${submission.formId}');
    print('🔍 Submission data keys: ${submission.data.keys.toList()}');
    print('🔍 Submission questionLabels: ${submission.questionLabels}');
    print('🔍 Submission questionAnswers: ${submission.questionAnswers}');

    try {
      print('🔍 Attempting to add document to submissions collection...');

      final docRef = await _firestore!.collection('submissions').add({
        ...submission.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('🔍 Submission created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('🔍 Error creating submission: $e');
      print('🔍 Error type: ${e.runtimeType}');
      print('🔍 Error details: $e');

      // Check if it's a permission error
      if (e.toString().contains('permission-denied')) {
        print('🔍 This is a permission denied error. Check Firestore rules.');
        print('🔍 Current user: ${currentUser?.uid ?? 'No user'}');
        print('🔍 Form ID: ${submission.formId}');

        // Try to get the form to check its status
        try {
          final formDoc = await _firestore!
              .collection('forms')
              .doc(submission.formId)
              .get();
          if (formDoc.exists) {
            final formData = formDoc.data();
            print('🔍 Form data: $formData');
            print('🔍 Form isPublic: ${formData?['isPublic']}');
            print('🔍 Form status: ${formData?['status']}');
          } else {
            print('🔍 Form document does not exist');
          }
        } catch (formError) {
          print('🔍 Could not check form data: $formError');
        }
      }

      rethrow;
    }
  }

  static Future<List<SubmissionModel>> getSubmissionsForForm(
      String formId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      // Try the optimized query first (requires index)
      final snapshot = await _firestore!
          .collection('submissions')
          .where('formId', isEqualTo: formId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('🔍 Index query failed, falling back to basic query: $e');

      // Fallback: Get all submissions for the form and sort locally
      final snapshot = await _firestore!
          .collection('submissions')
          .where('formId', isEqualTo: formId)
          .get();

      final submissions = snapshot.docs
          .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort locally by createdAt (most recent first)
      submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return submissions;
    }
  }

  static Future<void> updateSubmissionStatus(String submissionId, String status,
      {String? comment}) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    final updateData = {
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': currentUser?.uid,
    };
    if (comment != null) {
      updateData['decisionComment'] = comment;
    }

    await _firestore!
        .collection('submissions')
        .doc(submissionId)
        .update(updateData);
  }

  static Future<void> deleteSubmission(String submissionId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    await _firestore!.collection('submissions').doc(submissionId).delete();
  }

  static Stream<List<SubmissionModel>> getSubmissionsStream(String formId) {
    if (_firestore == null) throw Exception('Firestore not initialized');

    print('🔍 Getting submissions stream for form: $formId');

    try {
      // Try the optimized query first (requires index)
      return _firestore!
          .collection('submissions')
          .where('formId', isEqualTo: formId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        print('🔍 Submissions snapshot received: ${snapshot.docs.length} docs');
        final submissions = snapshot.docs.map((doc) {
          print(
              '🔍 Processing submission doc: ${doc.id} with data: ${doc.data()}');
          return SubmissionModel.fromMap(doc.data(), doc.id);
        }).toList();
        print('🔍 Processed ${submissions.length} submissions');
        return submissions;
      });
    } catch (e) {
      print('🔍 Index stream query failed, falling back to basic query: $e');

      // Fallback: Get all submissions for the form and sort locally
      return _firestore!
          .collection('submissions')
          .where('formId', isEqualTo: formId)
          .snapshots()
          .map((snapshot) {
        print('🔍 Submissions snapshot received: ${snapshot.docs.length} docs');
        final submissions = snapshot.docs.map((doc) {
          print(
              '🔍 Processing submission doc: ${doc.id} with data: ${doc.data()}');
          return SubmissionModel.fromMap(doc.data(), doc.id);
        }).toList();

        // Sort locally by createdAt (most recent first)
        submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        print(
            '🔍 Processed ${submissions.length} submissions (sorted locally)');
        return submissions;
      });
    }
  }

  // Check if a form is publicly accessible
  static Future<bool> isFormPubliclyAccessible(String formId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      final doc = await _firestore!.collection('forms').doc(formId).get();

      if (!doc.exists) {
        print('🔍 Form not found: $formId');
        return false;
      }

      final formData = doc.data();
      final status = formData?['status'] as String?;
      final isPublic =
          formData?['isPublic'] as bool? ?? true; // Default to public

      print('🔍 Form $formId - Status: $status, IsPublic: $isPublic');

      // Form is accessible if it's active and public
      return status == 'active' && isPublic;
    } catch (e) {
      print('🔍 Error checking form accessibility: $e');
      return false;
    }
  }

  // Check if a form exists (regardless of access permissions)
  static Future<bool> formExists(String formId) async {
    if (_firestore == null) return false;

    try {
      final doc = await _firestore!.collection('forms').doc(formId).get();
      return doc.exists;
    } catch (e) {
      print('🔍 Error checking if form exists: $e');
      return false;
    }
  }

  // Validate form access with optional token
  static Future<bool> validateFormAccess(String formId,
      {String? accessToken}) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      final doc = await _firestore!.collection('forms').doc(formId).get();

      if (!doc.exists) {
        print('🔍 Form not found: $formId');
        return false;
      }

      final formData = doc.data();
      final status = formData?['status'] as String?;
      final isPublic = formData?['isPublic'] as bool? ?? true;
      final requiredToken = formData?['accessToken'] as String?;

      print(
          '🔍 Form $formId - Status: $status, IsPublic: $isPublic, HasToken: ${requiredToken != null}');

      // If form is not active, deny access
      if (status != 'active') {
        print('🔍 Form $formId is not active (status: $status)');
        return false;
      }

      // If form is public, allow access
      if (isPublic) {
        print('🔍 Form $formId is publicly accessible');
        return true;
      }

      // If form requires token, validate it
      if (requiredToken != null && accessToken != null) {
        final isValid = requiredToken == accessToken;
        print('🔍 Form $formId token validation: $isValid');
        return isValid;
      }

      // If form requires token but none provided, deny access
      if (requiredToken != null && accessToken == null) {
        print('🔍 Form $formId requires access token but none provided');
        return false;
      }

      // Default to deny access for private forms
      print('🔍 Form $formId is private and no valid token provided');
      return false;
    } catch (e) {
      print('🔍 Error validating form access: $e');
      return false;
    }
  }

  // Migrate existing forms to include isPublic field
  static Future<void> migrateFormsToIncludeIsPublic() async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      print('🔧 Starting migration of forms to include isPublic field...');

      final formsSnapshot = await _firestore!.collection('forms').get();
      int migratedCount = 0;

      for (final doc in formsSnapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('isPublic')) {
          print('🔧 Migrating form ${doc.id} to include isPublic field');
          await _firestore!.collection('forms').doc(doc.id).update({
            'isPublic': true, // Default to public for existing forms
            'updatedAt': FieldValue.serverTimestamp(),
          });
          migratedCount++;
        }
      }

      print('🔧 Migration completed. ${migratedCount} forms updated.');
    } catch (e) {
      print('🔧 Error during form migration: $e');
      rethrow;
    }
  }

  // ==================== NOTIFICATION METHODS ====================

  // Get all notifications for the current user
  static Stream<List<NotificationModel>> getNotificationsStream() {
    if (_firestore == null) throw Exception('Firestore not initialized');
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      return _firestore!
          .collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('🔍 Error getting notifications stream: $e');
      // Fallback to basic query without ordering
      return _firestore!
          .collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .snapshots()
          .map((snapshot) {
        final notifications = snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList();
        // Sort locally by createdAt (most recent first)
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return notifications;
      });
    }
  }

  // Get unread notifications count
  static Stream<int> getUnreadNotificationsCountStream() {
    if (_firestore == null) throw Exception('Firestore not initialized');
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      return _firestore!
          .collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      print('🔍 Error getting unread notifications count: $e');
      return Stream.value(0);
    }
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      await _firestore!.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('🔍 Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  static Future<void> markAllNotificationsAsRead() async {
    if (_firestore == null) throw Exception('Firestore not initialized');
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      final batch = _firestore!.batch();
      final notificationsSnapshot = await _firestore!
          .collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notificationsSnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('🔍 Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Create a notification
  static Future<String> createNotification(NotificationModel notification,
      {required String userId}) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      final notificationData = notification.toMap();
      notificationData['userId'] = userId;

      final docRef =
          await _firestore!.collection('notifications').add(notificationData);

      return docRef.id;
    } catch (e) {
      print('🔍 Error creating notification: $e');
      rethrow;
    }
  }

  // Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    if (_firestore == null) throw Exception('Firestore not initialized');

    try {
      await _firestore!
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('🔍 Error deleting notification: $e');
      rethrow;
    }
  }

  // Create notification for form submission
  static Future<void> createFormSubmissionNotification({
    required String formId,
    required String submissionId,
    required String submitterName,
    required String submitterEmail,
    required String formTitle,
    required String formOwnerId,
  }) async {
    try {
      final notification = NotificationModel.formSubmission(
        formId: formId,
        submissionId: submissionId,
        submitterName: submitterName,
        submitterEmail: submitterEmail,
        formTitle: formTitle,
      );

      await createNotification(notification, userId: formOwnerId);
      print('✅ Form submission notification created for user: $formOwnerId');
    } catch (e) {
      print('❌ Error creating form submission notification: $e');
      // Don't rethrow - notification failure shouldn't break form submission
    }
  }

  // Create notification for form approval/rejection
  static Future<void> createFormStatusNotification({
    required String formId,
    required String formTitle,
    required String formOwnerId,
    required bool isApproved,
    String? reason,
  }) async {
    try {
      final notification = isApproved
          ? NotificationModel.formApproved(
              formId: formId,
              formTitle: formTitle,
            )
          : NotificationModel.formRejected(
              formId: formId,
              formTitle: formTitle,
              reason: reason,
            );

      await createNotification(notification, userId: formOwnerId);
      print('✅ Form status notification created for user: $formOwnerId');
    } catch (e) {
      print('❌ Error creating form status notification: $e');
      // Don't rethrow - notification failure shouldn't break form status update
    }
  }
}
