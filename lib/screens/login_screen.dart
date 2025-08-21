import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/screens/signup_screen.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/widgets/password_field.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage; // General error message
  String? _emailError; // Email-specific error
  String? _passwordError; // Password-specific error

  @override
  void initState() {
    super.initState();
    print('🔍 LoginScreen initialized');
    print('🔍 Firebase Auth instance: ${FirebaseAuth.instance}');
    print('🔍 Current user: ${FirebaseAuth.instance.currentUser}');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    print('🔍 Login attempt started');
    print('🔍 Email: ${_emailController.text.trim()}');
    print('🔍 Password length: ${_passwordController.text.length}');

    // Clear any existing errors before attempting login
    setState(() {
      _errorMessage = null;
      _emailError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      print('🔍 Form validation passed, proceeding with login');
      setState(() {
        _isLoading = true;
      });

      print('🔍 Dispatching SignInRequested event');
      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    } else {
      print('🔍 Form validation failed');
    }
  }

  // Method to clear all errors
  void _clearErrors() {
    setState(() {
      _errorMessage = null;
      _emailError = null;
      _passwordError = null;
    });
  }

  // Method to reset form and clear errors
  void _resetForm() {
    _formKey.currentState?.reset();
    _clearErrors();
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: KStyle.heading3TextStyle.copyWith(
            color: KStyle.cBlackColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive a password reset link.',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: KStyle.cPrimaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              onFieldSubmitted: (email) {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(
                      PasswordResetRequested(email: email),
                    );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final email = _emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(
                      PasswordResetRequested(email: email),
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KStyle.cPrimaryColor,
              foregroundColor: KStyle.cWhiteColor,
            ),
            child: Text(
              'Send',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.cWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Clear any lingering SnackBars
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });
    final isWide = MediaQuery.of(context).size.width > 900;
    final formMaxWidth = 400.0;
    return Scaffold(
      backgroundColor: KStyle.cWhiteColor,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  // Left: Image
                  Image.asset(
                    'assets/images/side_photo.png',
                    fit: BoxFit.contain,
                  ),
                  // Right: Login form
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 200),
                      color: KStyle.cWhiteColor,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 32),
                          child: BlocListener<AuthBloc, AuthState>(
                            listener: (context, state) {
                              print(
                                  '🔍 BlocListener triggered with state: ${state.runtimeType}');

                              if (state is AuthError) {
                                print(
                                    '🔍 AuthError received: ${state.message}');
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = state
                                      .message; // Store general error message

                                  // Parse error message to set field-specific errors
                                  final message = state.message.toLowerCase();
                                  print('🔍 Parsing error message: $message');

                                  if (message.contains('email') ||
                                      message.contains('user-not-found') ||
                                      message.contains('invalid-email')) {
                                    print('🔍 Setting email error');
                                    _emailError = state.message;
                                    _passwordError = null;
                                  } else if (message.contains('password') ||
                                      message.contains('wrong-password')) {
                                    print('🔍 Setting password error');
                                    _passwordError = state.message;
                                    _emailError = null;
                                  } else {
                                    // General error, clear field-specific errors
                                    print('🔍 Setting general error');
                                    _emailError = null;
                                    _passwordError = null;
                                  }
                                });

                                // Show snackbar for immediate feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              } else if (state is Authenticated) {
                                print('🔍 Authenticated state received');
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = null; // Clear general error
                                  _emailError = null; // Clear email error
                                  _passwordError = null; // Clear password error
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Welcome back,  ${state.user.displayName ?? state.user.email}!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // Navigate to HomeScreen after successful login
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              } else if (state is Unauthenticated) {
                                print('🔍 Unauthenticated state received');
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = null; // Clear general error
                                  _emailError = null; // Clear email error
                                  _passwordError = null; // Clear password error
                                });
                              } else if (state is AuthLoading) {
                                print('🔍 AuthLoading state received');
                              } else {
                                print(
                                    '🔍 Unknown state received: ${state.runtimeType}');
                              }
                            },
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_errorMessage != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                  // Logo and dot
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'form',
                                        style:
                                            KStyle.heading2TextStyle.copyWith(
                                          color: KStyle.cBlackColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 6, top: 8),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: KStyle.cPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    'Log in to your account.',
                                    style: KStyle.heading3TextStyle.copyWith(
                                      color: KStyle.cBlackColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 28,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 40),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: KStyle.cE3GreyColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: KStyle.cE3GreyColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: KStyle.cPrimaryColor,
                                            width: 2),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                      hintStyle: KStyle.labelMdRegularTextStyle
                                          .copyWith(
                                        color: KStyle.c72GreyColor,
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      print('🔍 Email changed: $value');
                                      // Clear email error when user starts typing
                                      if (_emailError != null) {
                                        setState(() {
                                          _emailError = null;
                                        });
                                      }
                                    },
                                    onTap: () {
                                      print('🔍 Email field tapped');
                                      // Clear email error when field is tapped
                                      if (_emailError != null) {
                                        setState(() {
                                          _emailError = null;
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      print('🔍 Validating email: $value');
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  // Display email error if exists
                                  if (_emailError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _emailError!,
                                        style: KStyle.labelSmRegularTextStyle
                                            .copyWith(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 18),
                                  PasswordField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    onChanged: (value) {
                                      print(
                                          '🔍 Password changed: ${value.length} characters');
                                      // Clear password error when user starts typing
                                      if (_passwordError != null) {
                                        setState(() {
                                          _passwordError = null;
                                        });
                                      }
                                    },
                                    onTap: () {
                                      print('🔍 Password field tapped');
                                      // Clear password error when field is tapped
                                      if (_passwordError != null) {
                                        setState(() {
                                          _passwordError = null;
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      print(
                                          '🔍 Validating password: ${value?.length ?? 0} characters');
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  // Display password error if exists
                                  if (_passwordError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _passwordError!,
                                        style: KStyle.labelSmRegularTextStyle
                                            .copyWith(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                            },
                                            activeColor: KStyle.cPrimaryColor,
                                          ),
                                          Text(
                                            'Remember me',
                                            style: KStyle
                                                .labelMdRegularTextStyle
                                                .copyWith(
                                              color: KStyle.cBlackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: _handleForgotPassword,
                                        child: Text(
                                          'Forgot Password?',
                                          style: KStyle.labelMdRegularTextStyle
                                              .copyWith(
                                            color: KStyle.cPrimaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: KStyle.cPrimaryColor,
                                        foregroundColor: KStyle.cWhiteColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Log In',
                                              style: KStyle.labelMdBoldTextStyle
                                                  .copyWith(
                                                color: KStyle.cWhiteColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Don\'t have an account? ',
                                        style: KStyle.labelMdRegularTextStyle
                                            .copyWith(
                                          color: KStyle.c72GreyColor,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushReplacementNamed('/signup');
                                        },
                                        child: Text(
                                          'Create an account',
                                          style: KStyle.labelMdRegularTextStyle
                                              .copyWith(
                                            color: KStyle.cPrimaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top logo and dot
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'form',
                          style: KStyle.heading2TextStyle.copyWith(
                            color: KStyle.cBlackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 6, top: 8),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: KStyle.cPrimaryColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Log in to your account.',
                      style: KStyle.heading3TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: KStyle.cE3GreyColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: KStyle.cE3GreyColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: KStyle.cPrimaryColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                hintStyle:
                                    KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.c72GreyColor,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                // Clear email error when user starts typing
                                if (_emailError != null) {
                                  setState(() {
                                    _emailError = null;
                                  });
                                }
                              },
                              onTap: () {
                                // Clear email error when field is tapped
                                if (_emailError != null) {
                                  setState(() {
                                    _emailError = null;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            // Display email error if exists
                            if (_emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _emailError!,
                                  style:
                                      KStyle.labelSmRegularTextStyle.copyWith(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                            PasswordField(
                              controller: _passwordController,
                              hintText: 'Password',
                              onChanged: (value) {
                                // Clear password error when user starts typing
                                if (_passwordError != null) {
                                  setState(() {
                                    _passwordError = null;
                                  });
                                }
                              },
                              onTap: () {
                                // Clear password error when field is tapped
                                if (_passwordError != null) {
                                  setState(() {
                                    _passwordError = null;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            // Display password error if exists
                            if (_passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _passwordError!,
                                  style:
                                      KStyle.labelSmRegularTextStyle.copyWith(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: KStyle.cPrimaryColor,
                                    ),
                                    Text(
                                      'Remember me',
                                      style: KStyle.labelMdRegularTextStyle
                                          .copyWith(
                                        color: KStyle.cBlackColor,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _handleForgotPassword,
                                  child: Text(
                                    'Forgot Password?',
                                    style:
                                        KStyle.labelMdRegularTextStyle.copyWith(
                                      color: KStyle.cPrimaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Test button for debugging (remove in production)
                            if (kDebugMode)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _emailError =
                                                  'Test email error message';
                                              _passwordError = null;
                                              _errorMessage = null;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Test Email Error'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _passwordError =
                                                  'Test password error message';
                                              _emailError = null;
                                              _errorMessage = null;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                          child:
                                              const Text('Test Password Error'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KStyle.cPrimaryColor,
                                  foregroundColor: KStyle.cWhiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Log In',
                                        style: KStyle.labelMdBoldTextStyle
                                            .copyWith(
                                          color: KStyle.cWhiteColor,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account? ',
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
                                    color: KStyle.c72GreyColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/signup');
                                  },
                                  child: Text(
                                    'Create an account',
                                    style:
                                        KStyle.labelMdRegularTextStyle.copyWith(
                                      color: KStyle.cPrimaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
