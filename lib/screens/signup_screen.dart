import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/widgets/password_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Add debugging information
      print('🔍 Starting signup process...');
      print('📝 Full Name: ${_fullNameController.text.trim()}');
      print('📧 Email: ${_emailController.text.trim()}');
      print('🔒 Password length: ${_passwordController.text.length}');

      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _fullNameController.text.trim(),
            ),
          );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KStyle.cWhiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: KStyle.cBlackColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });

            // Show error in a more prominent way
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Account Creation Failed',
                      style: KStyle.heading3TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  state.message,
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: KStyle.cPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is Authenticated) {
            // Success - show success message and route to login screen
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Account created successfully! Please sign in to continue.'),
                backgroundColor: Colors.green,
              ),
            );

            // Route to login screen
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 500,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
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
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: KStyle.cPrimaryColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Create your account.',
                        style: KStyle.heading3TextStyle.copyWith(
                          color: KStyle.cPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name Field
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: KStyle.cE3GreyColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: KStyle.cE3GreyColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: KStyle.cPrimaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: KStyle.cE3GreyColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: KStyle.cE3GreyColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: KStyle.cPrimaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      PasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      PasswordField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 24),

                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: KStyle.labelMdBoldTextStyle.copyWith(
                                    color: KStyle.cWhiteColor,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed('/login'),
                            child: Text(
                              'Log In',
                              style: KStyle.labelMdRegularTextStyle.copyWith(
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
    );
  }
}
