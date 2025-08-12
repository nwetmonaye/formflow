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
import 'package:formflow/screens/form_submission_screen.dart';
import 'package:formflow/screens/form_detail_screen.dart';
import 'package:formflow/screens/form_preview_screen.dart';

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
        onGenerateInitialRoutes: (String initialRoute) {
          print('🔍 onGenerateInitialRoutes called with: $initialRoute');

          // Check if the initial route is a form route
          if (initialRoute.startsWith('/form/')) {
            print('🔍 Initial route is a form route, handling it directly');

            // Parse the URI first to handle query parameters correctly
            Uri uri = Uri.parse(initialRoute);
            print('🔍 Parsed URI: $uri');
            print('🔍 Path segments: ${uri.pathSegments}');
            print('🔍 Query parameters: ${uri.queryParameters}');

            // Extract form ID from the path segments
            String formId = '';
            if (uri.pathSegments.length > 1) {
              formId =
                  uri.pathSegments[1]; // /form/{formId} -> formId is at index 1
            }
            print('🔍 Extracted form ID: $formId');

            // Check if this is a view request
            bool isViewRequest = uri.queryParameters['view'] == 'true';
            print('🔍 Is view request: $isViewRequest');

            if (isViewRequest) {
              // This is a view request - show form detail screen
              print('🔍 Routing to FormDetailScreen with formId: $formId');
              return [
                MaterialPageRoute(
                  builder: (context) => FormDetailScreen(formId: formId),
                ),
              ];
            }

            // Default to form submission screen for public access
            print('🔍 Routing to FormSubmissionScreen with formId: $formId');
            return [
              MaterialPageRoute(
                builder: (context) => FormSubmissionScreen(formId: formId),
              ),
            ];
          }

          // Default to auth wrapper for other routes
          print('🔍 Initial route is not a form route, using AuthWrapper');
          return [
            MaterialPageRoute(
              builder: (context) => const AuthWrapper(),
            ),
          ];
        },
        onGenerateRoute: (settings) {
          print('🔍 onGenerateRoute called with: ${settings.name}');

          // Handle specific named routes
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) => const AuthWrapper(),
              );
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            case '/signup':
              return MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
          }

          // Handle dynamic form routes like /form/{formId}
          if (settings.name?.startsWith('/form/') == true) {
            print('🔍 Processing form route: ${settings.name}');

            // Parse the URI first to handle query parameters correctly
            Uri uri = Uri.parse(settings.name!);
            print('🔍 Parsed URI: $uri');
            print('🔍 Path segments: ${uri.pathSegments}');
            print('🔍 Query parameters: ${uri.queryParameters}');

            // Extract form ID from the path segments
            String formId = '';
            if (uri.pathSegments.length > 1) {
              formId =
                  uri.pathSegments[1]; // /form/{formId} -> formId is at index 1
            }
            print('🔍 Extracted form ID: $formId');

            // Check if this is a view request
            bool isViewRequest = uri.queryParameters['view'] == 'true';
            print('🔍 Is view request: $isViewRequest');

            if (isViewRequest) {
              // This is a view request - show form detail screen
              print('🔍 Routing to FormDetailScreen with formId: $formId');
              return MaterialPageRoute(
                builder: (context) => FormDetailScreen(formId: formId),
              );
            }

            // Default to form submission screen for public access
            print('🔍 Routing to FormSubmissionScreen with formId: $formId');
            return MaterialPageRoute(
              builder: (context) => FormSubmissionScreen(formId: formId),
            );
          }
          print('🔍 No matching route found, returning null');
          return null;
        },
        // Ensure proper handling of unknown routes
        onUnknownRoute: (settings) {
          print('🔍 onUnknownRoute called with: ${settings.name}');
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          );
        },
      ),
    );
  }
}
