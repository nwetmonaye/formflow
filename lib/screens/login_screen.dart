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
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Welcome back,  ${state.user.displayName ?? state.user.email}!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                    validator: (value) {
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
                                  const SizedBox(height: 18),
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
                            const SizedBox(height: 18),
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
