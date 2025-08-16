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
        initialRoute: Uri.base.path + Uri.base.query,
        onGenerateInitialRoutes: (initialRoute) {
          print('🔍 onGenerateInitialRoutes called with: $initialRoute');
          print('🔍 Route type: ${initialRoute.runtimeType}');
          print('🔍 Route length: ${initialRoute.length}');
          print('🔍 Route contains /form/: ${initialRoute.contains('/form/')}');

          // Handle form routes first - these should bypass auth wrapper
          if (initialRoute.startsWith('/form/')) {
            print('🔍 Initial route is a form route: $initialRoute');

            // Parse the URI to extract form ID and query parameters
            Uri uri = Uri.parse(initialRoute);
            print('🔍 Parsed URI: $uri');
            print('🔍 Path segments: ${uri.pathSegments}');
            print('🔍 Query parameters: ${uri.queryParameters}');
            print('🔍 Full URI string: ${uri.toString()}');

            // Extract form ID from the path segments
            String formId = '';
            if (uri.pathSegments.length > 1) {
              formId =
                  uri.pathSegments[1]; // /form/{formId} -> formId is at index 1
            }
            print('🔍 Extracted form ID: $formId');

            if (formId.isEmpty) {
              print('🔍 No form ID found, defaulting to AuthWrapper');
              return [
                MaterialPageRoute(
                  builder: (context) => const AuthWrapper(),
                ),
              ];
            }

            // Check if this is a view request (for form creators to preview)
            bool isViewRequest = uri.queryParameters['view'] == 'true';
            print('🔍 Is view request: $isViewRequest');

            if (isViewRequest) {
              // This is a view request - show form detail screen for form creators
              print(
                  '🔍 Routing to FormDetailScreen with formId: $formId (preview mode)');
              return [
                MaterialPageRoute(
                  builder: (context) => FormDetailScreen(formId: formId),
                ),
              ];
            }

            // Default to form submission screen for public access (form responders)
            print(
                '🔍 Routing to FormSubmissionScreen with formId: $formId (submission mode)');
            return [
              MaterialPageRoute(
                builder: (context) => FormSubmissionScreen(formId: formId),
              ),
            ];
          }

          // Handle test route for debugging
          if (initialRoute == '/test-form') {
            print('🔍 Test route accessed in initial routes');
            return [
              MaterialPageRoute(
                builder: (context) =>
                    const FormSubmissionScreen(formId: 'sample-form-1'),
              ),
            ];
          }

          // Default to auth wrapper for other routes
          print('🔍 Initial route is not a form route, using AuthWrapper');
          print('🔍 Route will be handled by onGenerateRoute');
          return [
            MaterialPageRoute(
              builder: (context) => const AuthWrapper(),
            ),
          ];
        },
        onGenerateRoute: (settings) {
          print('🔍 onGenerateRoute called with: ${settings.name}');
          print('🔍 Settings arguments: ${settings.arguments}');

          // Handle form routes FIRST - these should take priority
          if (settings.name?.startsWith('/form/') == true) {
            print(
                '🔍 Processing form route in onGenerateRoute: ${settings.name}');

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

            if (formId.isEmpty) {
              print('🔍 No form ID found in onGenerateRoute, returning null');
              return null;
            }

            // Check if this is a view request (for form creators to preview)
            bool isViewRequest = uri.queryParameters['view'] == 'true';
            print('🔍 Is view request: $isViewRequest');

            if (isViewRequest) {
              // This is a view request - show form detail screen for form creators
              print(
                  '🔍 Routing to FormDetailScreen with formId: $formId (preview mode)');
              return MaterialPageRoute(
                builder: (context) => FormDetailScreen(formId: formId),
              );
            }

            // Default to form submission screen for public access (form responders)
            print(
                '🔍 Routing to FormSubmissionScreen with formId: $formId (submission mode)');
            return MaterialPageRoute(
              builder: (context) => FormSubmissionScreen(formId: formId),
            );
          }

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
            // Add test route for debugging
            case '/test-form':
              print('🔍 Test route accessed - showing sample form');
              return MaterialPageRoute(
                builder: (context) =>
                    const FormSubmissionScreen(formId: 'sample-form-1'),
              );
            // Add debug route to show current routing state
            case '/debug-routing':
              print('🔍 Debug route accessed');
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Routing Debug')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Routing Debug Information',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 20),
                        Text('Current Route: ${settings.name}'),
                        const SizedBox(height: 10),
                        Text('Arguments: ${settings.arguments}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/test-form'),
                          child: const Text('Test Form Route'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed('/form/sample-form-1'),
                          child: const Text('Test Form Submission'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed('/form/sample-form-1?view=true'),
                          child: const Text('Test Form Preview'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }

          print('🔍 No matching route found, returning null');
          return null;
        },
        // Ensure proper handling of unknown routes
        onUnknownRoute: (settings) {
          print('🔍 onUnknownRoute called with: ${settings.name}');
          print('🔍 Unknown route settings: ${settings.toString()}');

          // If it's a form-like route that wasn't caught, try to handle it
          if (settings.name?.startsWith('/form/') == true) {
            print(
                '🔍 Unknown route looks like a form route, attempting to parse...');
            try {
              Uri uri = Uri.parse(settings.name!);
              String formId = '';
              if (uri.pathSegments.length > 1) {
                formId = uri.pathSegments[1];
              }
              if (formId.isNotEmpty) {
                print('🔍 Extracted form ID from unknown route: $formId');
                return MaterialPageRoute(
                  builder: (context) => FormSubmissionScreen(formId: formId),
                );
              }
            } catch (e) {
              print('🔍 Error parsing unknown route: $e');
            }
          }

          print('🔍 Falling back to HomeScreen for unknown route');
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          );
        },
      ),
    );
  }
}
