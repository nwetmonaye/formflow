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
                    fit: BoxFit.fill,
                  ),
                  // Right: Sign up form
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
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red, size: 24),
                                        const SizedBox(width: 8),
                                        Text('Account Creation Failed',
                                            style: KStyle.heading3TextStyle
                                                .copyWith(
                                                    color: KStyle.cBlackColor)),
                                      ],
                                    ),
                                    content: Text(state.message,
                                        style: KStyle.labelMdRegularTextStyle
                                            .copyWith(
                                                color: KStyle.c72GreyColor)),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('OK',
                                            style: KStyle
                                                .labelMdRegularTextStyle
                                                .copyWith(
                                                    color:
                                                        KStyle.cPrimaryColor)),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (state is Authenticated) {
                                setState(() {
                                  _isLoading = false;
                                });

                                // Sign out the user after successful signup to require them to sign in
                                context
                                    .read<AuthBloc>()
                                    .add(SignOutRequested());

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Account created successfully! Please sign in to continue.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Navigate to login screen
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
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
                                    'Create your account.',
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
                                    controller: _fullNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Full Name',
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
                                    textCapitalization:
                                        TextCapitalization.words,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
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
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
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
                                    validator: _validatePassword,
                                  ),
                                  const SizedBox(height: 18),
                                  PasswordField(
                                    controller: _confirmPasswordController,
                                    hintText: 'Confirm Password',
                                    validator: _validateConfirmPassword,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _handleSignUp,
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
                                              'Create Account',
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
                                        'Already have an account? ',
                                        style: KStyle.labelMdRegularTextStyle
                                            .copyWith(
                                          color: KStyle.c72GreyColor,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.of(context)
                                            .pushReplacementNamed('/login'),
                                        child: Text(
                                          'Log In',
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
                      'Create your account.',
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
                      child: BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthError) {
                            setState(() {
                              _isLoading = false;
                            });
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 24),
                                    const SizedBox(width: 8),
                                    Text('Account Creation Failed',
                                        style: KStyle.heading3TextStyle
                                            .copyWith(
                                                color: KStyle.cBlackColor)),
                                  ],
                                ),
                                content: Text(state.message,
                                    style: KStyle.labelMdRegularTextStyle
                                        .copyWith(color: KStyle.c72GreyColor)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('OK',
                                        style: KStyle.labelMdRegularTextStyle
                                            .copyWith(
                                                color: KStyle.cPrimaryColor)),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is Authenticated) {
                            setState(() {
                              _isLoading = false;
                            });

                            // Sign out the user after successful signup to require them to sign in
                            context.read<AuthBloc>().add(SignOutRequested());

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Account created successfully! Please sign in to continue.'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Navigate to login screen
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          }
                        },
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _fullNameController,
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
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
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
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
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
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
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 18),
                              PasswordField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm Password',
                                validator: _validateConfirmPassword,
                              ),
                              const SizedBox(height: 32),
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
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Create Account',
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
                                    'Already have an account? ',
                                    style:
                                        KStyle.labelMdRegularTextStyle.copyWith(
                                      color: KStyle.c72GreyColor,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushReplacementNamed('/login'),
                                    child: Text(
                                      'Log In',
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
                  ],
                ),
              ),
      ),
    );
  }
}
