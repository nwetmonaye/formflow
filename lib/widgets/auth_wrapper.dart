import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:formflow/services/firebase_service.dart';
import 'dart:async'; // Added for StreamSubscription

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = false;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _initializeAuth() async {
    if (_isInitializing)
      return; // Prevent multiple simultaneous initializations

    setState(() {
      _isInitializing = true;
    });

    try {
      // First ensure Firebase is initialized
      await FirebaseService.ensureInitialized();
      print('🔍 AuthWrapper: Firebase initialization completed');

      // Cancel any existing subscription
      _authStateSubscription?.cancel();

      // Listen to Firebase auth state changes
      _authStateSubscription =
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
        print(
            '🔍 AuthWrapper: Firebase auth state changed: ${user?.uid ?? 'null'}');
        if (mounted) {
          // Only trigger auth check if we haven't already done so recently
          context.read<AuthBloc>().add(AuthCheckRequested());
        }
      });

      // Check the current auth state immediately
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('🔍 AuthWrapper: Current user found: ${currentUser.uid}');
        if (mounted) {
          context.read<AuthBloc>().add(AuthCheckRequested());
        }
      } else {
        print('🔍 AuthWrapper: No current user found');
        if (mounted) {
          context.read<AuthBloc>().add(AuthCheckRequested());
        }
      }
    } catch (error) {
      print('🔍 AuthWrapper: Firebase initialization failed: $error');
      // Even if Firebase fails, we should still check auth state
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Debug: Print current auth state
        print('🔍 AuthWrapper: Current state is ${state.runtimeType}');
        if (state is Authenticated) {
          print(
              '🔍 AuthWrapper: User is authenticated with UID: ${state.user?.uid}');
        }

        if (state is AuthInitial) {
          // Check current auth state when widget initializes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<AuthBloc>().add(AuthCheckRequested());
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is Authenticated) {
          return const HomeScreen();
        }

        // Unauthenticated or AuthError - show login screen
        return const LoginScreen();
      },
    );
  }
}
