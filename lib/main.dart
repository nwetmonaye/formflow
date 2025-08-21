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
import 'package:formflow/models/form_model.dart' as form_model;

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

          // Handle form routes first - these should bypass auth wrapper for public access
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
            // This bypasses authentication - anyone can access the form
            print(
                '🔍 Routing to FormSubmissionScreen with formId: $formId (public submission mode)');

            // Check if there's an access token in the URL
            String? accessToken = uri.queryParameters['token'];
            if (accessToken != null) {
              print(
                  '🔍 Access token provided: ${accessToken.substring(0, 8)}...');
            }

            return [
              MaterialPageRoute(
                builder: (context) => FormSubmissionScreen(
                  formId: formId,
                  accessToken: accessToken,
                ),
              ),
            ];
          }

          // Handle test route for debugging
          if (initialRoute == '/test-form') {
            print('🔍 Test route accessed in initial routes');
            return [
              MaterialPageRoute(
                builder: (context) => const FormSubmissionScreen(
                  formId: 'sample-form-1',
                  accessToken: null,
                ),
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

          // Handle form routes FIRST - these should take priority and bypass auth
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
            // This bypasses authentication - anyone can access the form
            print(
                '🔍 Routing to FormSubmissionScreen with formId: $formId (public submission mode)');

            // Check if there's an access token in the URL
            String? accessToken = uri.queryParameters['token'];
            if (accessToken != null) {
              print(
                  '🔍 Access token provided: ${accessToken.substring(0, 8)}...');
            }

            return MaterialPageRoute(
              builder: (context) => FormSubmissionScreen(
                formId: formId,
                accessToken: accessToken,
              ),
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
                builder: (context) => const FormSubmissionScreen(
                  formId: 'sample-form-1',
                  accessToken: null,
                ),
              );
            // Add test route for creating a sample form
            case '/create-test-form':
              print('🔍 Create test form route accessed');
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Create Test Form')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Creating test form...'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            // Create a test form
                            try {
                              final testForm = form_model.FormModel(
                                title: 'Test Public Form',
                                description:
                                    'This is a test form to verify public access',
                                fields: [
                                  form_model.FormField(
                                    id: 'name',
                                    label: 'Your Name',
                                    type: 'text',
                                    required: true,
                                  ),
                                  form_model.FormField(
                                    id: 'email',
                                    label: 'Your Email',
                                    type: 'text',
                                    required: true,
                                  ),
                                ],
                                createdBy: 'test-user',
                                isPublic: true,
                                status: 'active',
                              );

                              final formId =
                                  await FirebaseService.createForm(testForm);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Test form created with ID: $formId'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error creating test form: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text('Create Test Form'),
                        ),
                      ],
                    ),
                  ),
                ),
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
                        const SizedBox(height: 20),
                        const Text('Form Access Testing:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed('/create-test-form'),
                          child: const Text('Create Test Form'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                            'After creating a test form, copy the link and test it in another browser/incognito window.'),
                        const SizedBox(height: 10),
                        const Text(
                            'The form should be accessible without authentication if isPublic is true.'),
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

                // Check if there's an access token in the URL
                String? accessToken = uri.queryParameters['token'];
                if (accessToken != null) {
                  print(
                      '🔍 Access token provided: ${accessToken.substring(0, 8)}...');
                }

                // Route to form submission screen for public access
                return MaterialPageRoute(
                  builder: (context) => FormSubmissionScreen(
                    formId: formId,
                    accessToken: accessToken,
                  ),
                );
              }
            } catch (e) {
              print('🔍 Error parsing unknown route: $e');
            }
          }

          // For any other unknown route, show a user-friendly error page
          print('🔍 Falling back to error page for unknown route');
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Page Not Found'),
                backgroundColor: KStyle.cPrimaryColor,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: KStyle.c72GreyColor,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Page Not Found',
                      style: KStyle.heading2TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The page you are looking for does not exist.',
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KStyle.cPrimaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Go to Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
