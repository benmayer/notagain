/// Sign Up Screen
/// 
/// Handles new user registration with email, password, and name
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;
  late WebViewController _termsWebViewController;
  late WebViewController _privacyWebViewController;

  @override
  void initState() {
    super.initState();
    _termsWebViewController = WebViewController()
      ..loadRequest(
        Uri.parse('https://example.com/terms'), // Replace with actual URL
      );
    _privacyWebViewController = WebViewController()
      ..loadRequest(
        Uri.parse('https://example.com/privacy'), // Replace with actual URL
      );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showTermsBottomSheet() {
    showFSheet(
      context: context,
      side: FLayout.btt,
      draggable: false,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: context.theme.colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
        ),
        child: Column(
          children: [
            // Header with title and close button
            Padding(
              padding: EdgeInsets.all(AppConstants.standardPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    'Terms of Service',
                    style: context.theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      FIcons.x,
                      color: context.theme.colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.theme.colors.border, height: 1),
            // WebView
            Expanded(
              child: WebViewWidget(
                controller: _termsWebViewController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyBottomSheet() {
    showFSheet(
      context: context,
      side: FLayout.btt,
      draggable: false,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: context.theme.colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
        ),
        child: Column(
          children: [
            // Header with title and close button
            Padding(
              padding: EdgeInsets.all(AppConstants.standardPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    'Privacy Policy',
                    style: context.theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      FIcons.x,
                      color: context.theme.colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.theme.colors.border, height: 1),
            // WebView
            Expanded(
              child: WebViewWidget(
                controller: _privacyWebViewController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignup(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      showFToast(
        context: context,
        alignment: FToastAlignment.bottomCenter,
        icon: Icon(FIcons.triangleAlert, color: context.theme.colors.primary),
        title: const Text('Terms Required'),
        description: const Text('Please agree to the terms of service'),
        duration: AppConstants.toastDuration,
        style: (style) => style.copyWith(
          constraints: style.constraints.copyWith(minWidth: AppConstants.toastMinWidth),
        ),
      );
      return;
    }

    final result = await authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      // Navigate to home screen via go_router
      context.go('/home');
    } else {
      // Show Forui toast notification
      showFToast(
        context: context,
        alignment: FToastAlignment.bottomCenter,
        icon: Icon(FIcons.triangleAlert, color: context.theme.colors.destructive),
        title: const Text('Signup Failed'),
        description: Text(result.error?.message ?? AppConstants.defaultErrorMessage),
        duration: AppConstants.toastDuration,
        style: (style) => style.copyWith(
          constraints: style.constraints.copyWith(minWidth: AppConstants.toastMinWidth),
        ),
      );
    }
  }

  void _handleAppleSignIn(AuthProvider authProvider) async {
    final result = await authProvider.signInWithApple();

    if (!mounted) return;

    if (result.isSuccess) {
      context.go('/home');
    } else {
      showFToast(
        context: context,
        alignment: FToastAlignment.bottomCenter,
        icon: Icon(FIcons.triangleAlert, color: context.theme.colors.destructive),
        title: const Text('Apple Sign-In Failed'),
        description: Text(result.error?.message ?? AppConstants.defaultErrorMessage),
        duration: AppConstants.toastDuration,
        style: (style) => style.copyWith(
          constraints: style.constraints.copyWith(minWidth: AppConstants.toastMinWidth),
        ),
      );
    }
  }

  void _handleGoogleSignIn(AuthProvider authProvider) async {
    final result = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (result.isSuccess) {
      context.go('/home');
    } else {
      showFToast(
        context: context,
        alignment: FToastAlignment.bottomCenter,
        icon: Icon(FIcons.triangleAlert, color: context.theme.colors.destructive),
        title: const Text('Google Sign-In Failed'),
        description: Text(result.error?.message ?? AppConstants.defaultErrorMessage),
        duration: AppConstants.toastDuration,
        style: (style) => style.copyWith(
          constraints: style.constraints.copyWith(minWidth: AppConstants.toastMinWidth),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Create Account'),
        prefixes: [
          FHeaderAction.back(onPress: () => context.go('/')),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Full Name Field
                    FTextFormField(
                      control: FTextFieldControl.managed(controller: _nameController),
                      label: const Text('Full Name'),
                      hint: 'John Doe',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: AppConstants.standardGap),

                    // Email Field
                    FTextFormField.email(
                      control: FTextFieldControl.managed(controller: _emailController),
                      label: const Text('Email'),
                      hint: 'john@example.com',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                        if (!RegExp(pattern).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: AppConstants.standardGap),

                    // Password Field
                    FTextFormField.password(
                      control: FTextFieldControl.managed(controller: _passwordController),
                      label: const Text('Password'),
                      hint: 'Enter your password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < AppConstants.minPasswordLength) {
                          return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    FTextFormField.password(
                      control: FTextFieldControl.managed(controller: _confirmPasswordController),
                      label: const Text('Confirm Password'),
                      hint: 'Re-enter your password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: AppConstants.largeGap),

                    // Terms Agreement Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FCheckbox(
                          value: _agreedToTerms,
                          onChange: (value) {
                            setState(() => _agreedToTerms = value);
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: context.theme.typography.sm.copyWith(
                                      color: context.theme.colors.foreground,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: context.theme.typography.sm.copyWith(
                                      color: context.theme.colors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showTermsBottomSheet,
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: context.theme.typography.sm.copyWith(
                                      color: context.theme.colors.foreground,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: context.theme.typography.sm.copyWith(
                                      color: context.theme.colors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showPrivacyBottomSheet,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.largeGap),

                    // Sign Up Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return FButton(
                          onPress: (!_agreedToTerms || authProvider.isLoading) 
                            ? null 
                            : () => _handleSignup(authProvider),
                          prefix: authProvider.isLoading 
                            ? const FCircularProgress() 
                            : null,
                          style: FButtonStyle.primary(),
                          child: Text(
                            authProvider.isLoading ? 'Creating Account...' : 'Create Account'
                          ),
                        );
                      },
                    ),
                    SizedBox(height: AppConstants.largeGap),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: context.theme.colors.border,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppConstants.standardPadding),
                          child: Text(
                            'or',
                            style: context.theme.typography.sm.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: context.theme.colors.border,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.largeGap),

                    // Social Auth Buttons
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FButton(
                              onPress: authProvider.isLoading ? null : () => _handleAppleSignIn(authProvider),
                              prefix: authProvider.isLoading ? const FCircularProgress() : const Icon(FIcons.apple),
                              style: FButtonStyle.outline(),
                              child: const Text('Continue with Apple'),
                            ),
                            const SizedBox(height: 12),
                            FButton(
                              onPress: authProvider.isLoading ? null : () => _handleGoogleSignIn(authProvider),
                              prefix: authProvider.isLoading ? const FCircularProgress() : const Icon(FIcons.mail),
                              style: FButtonStyle.outline(),
                              child: const Text('Continue with Google'),
                            ),
                          ],
                        );
                      },
                    ),
                    ],
                  ),
                ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.standardPadding, vertical: AppConstants.standardPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.foreground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign In',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
