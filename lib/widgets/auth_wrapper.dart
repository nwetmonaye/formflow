import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to Firebase auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print(
          '🔍 AuthWrapper: Firebase auth state changed: ${user?.uid ?? 'null'}');
      if (user != null) {
        // User is signed in, check auth state
        context.read<AuthBloc>().add(AuthCheckRequested());
      } else {
        // User is signed out
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
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
            context.read<AuthBloc>().add(AuthCheckRequested());
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
