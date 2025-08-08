import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/screens/signup_screen.dart';
import 'package:formflow/widgets/password_field.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
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
    return Scaffold(
      backgroundColor: KStyle.cWhiteColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is Authenticated) {
            // Success - user will be automatically routed to home screen via AuthWrapper
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Welcome back, ${state.user.displayName ?? state.user.email}!'),
                backgroundColor: Colors.green,
              ),
            );
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
                        'Log in to your account.',
                        style: KStyle.heading3TextStyle.copyWith(
                          color: KStyle.cPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),

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
                      const SizedBox(height: 16),

                      // Remember me and Forgot Password
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
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _handleForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: KStyle.labelMdRegularTextStyle.copyWith(
                                color: KStyle.cPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Login Button
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Log In',
                                  style: KStyle.labelMdBoldTextStyle.copyWith(
                                    color: KStyle.cWhiteColor,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Create Account Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/signup');
                            },
                            child: Text(
                              'Create Account',
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
