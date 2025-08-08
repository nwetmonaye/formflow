import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/services/auth_service.dart';
import 'package:formflow/widgets/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:formflow/screens/login_screen.dart';
import 'package:formflow/screens/signup_screen.dart';
import 'package:formflow/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initializeFirebase();

  // Check Firebase Auth configuration
  await AuthService.checkAuthConfiguration();

  runApp(const FormFlowApp());
}

class FormFlowApp extends StatelessWidget {
  const FormFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Form Flow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: KStyle.cPrimaryColor,
            primary: KStyle.cPrimaryColor,
            background: KStyle.cBgColor,
          ),
          fontFamily: 'Plus Jakarta Sans',
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
