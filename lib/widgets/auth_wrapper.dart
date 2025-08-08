import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          context.read<AuthBloc>().add(AuthCheckRequested());
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
