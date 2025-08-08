import 'package:firebase_auth/firebase_auth.dart';
import 'package:formflow/models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  static UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  // Stream of auth state changes
  static Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user != null) {
        return UserModel.fromFirebaseUser(user);
      }
      return null;
    });
  }

  // Sign in with email and password
  static Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Check if Firebase Auth is initialized
      if (_auth == null) {
        throw Exception(
            'Firebase Auth is not initialized. Please check your Firebase configuration.');
      }

      print('Signing in with email: $email');

      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Sign in successful: ${userCredential.user?.uid}');

      if (userCredential.user != null) {
        return UserModel.fromFirebaseUser(userCredential.user!);
      } else {
        throw Exception('Sign in failed: No user returned from Firebase');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'user-not-found':
          message =
              'No user found with this email address. Please check your email or create a new account.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email address. Please enter a valid email.';
          break;
        case 'user-disabled':
          message =
              'This user account has been disabled. Please contact support.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection and try again.';
          break;
        default:
          message = 'Sign in failed: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(message);
    } catch (e) {
      print('General Exception during sign in: $e');
      throw Exception('Sign in failed: $e');
    }
  }

  // Create user with email and password
  static Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Check if Firebase Auth is initialized
      if (_auth == null) {
        throw Exception(
            'Firebase Auth is not initialized. Please check your Firebase configuration.');
      }

      print('Creating user with email: $email');

      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully: ${userCredential.user?.uid}');

      if (userCredential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          try {
            await userCredential.user!.updateDisplayName(displayName);
            print('Display name updated: $displayName');
          } catch (e) {
            print('Warning: Could not update display name: $e');
            // Don't throw error for display name update failure
          }
        }

        return UserModel.fromFirebaseUser(userCredential.user!);
      } else {
        throw Exception(
            'Account creation failed: No user returned from Firebase');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'weak-password':
          message =
              'The password provided is too weak. Please use a stronger password.';
          break;
        case 'email-already-in-use':
          message =
              'An account already exists with this email address. Please try signing in instead.';
          break;
        case 'invalid-email':
          message = 'Invalid email address. Please enter a valid email.';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password accounts are not enabled. Please contact support.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection and try again.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          break;
        default:
          message = 'Account creation failed: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(message);
    } catch (e) {
      print('General Exception during account creation: $e');
      throw Exception('Account creation failed: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Password reset failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Check if user is signed in
  static bool get isSignedIn {
    return _auth?.currentUser != null;
  }

  // Check Firebase Auth configuration
  static Future<bool> checkAuthConfiguration() async {
    try {
      if (_auth == null) {
        print('❌ Firebase Auth is not initialized');
        return false;
      }

      print('✅ Firebase Auth is initialized');
      print('📧 Current user: ${_auth!.currentUser?.email ?? 'None'}');
      print('🆔 Current user ID: ${_auth!.currentUser?.uid ?? 'None'}');

      return true;
    } catch (e) {
      print('❌ Error checking Firebase Auth configuration: $e');
      return false;
    }
  }
}
