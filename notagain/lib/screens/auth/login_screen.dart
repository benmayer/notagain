/// Login Screen
/// 
/// Handles user authentication with email and password
/// Includes options for social authentication (Apple, Google)
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    debugPrint('🔍 [LOGIN] Starting email login...');
    final result = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    debugPrint('🔍 [LOGIN] Got result - isSuccess: ${result.isSuccess}');

    if (!mounted) return;

    if (result.isSuccess) {
      // Check if onboarding is complete and navigate accordingly
      final user = result.data;
      final onboardingCompleted = user?.onboardingCompleted ?? false;
      debugPrint('🔍 [LOGIN] User: ${user?.email}, onboardingCompleted=$onboardingCompleted');
      
      if (onboardingCompleted) {
        debugPrint('🔄 [LOGIN] Navigating to /home (onboarding complete)');
        context.go('/home');
      } else {
        debugPrint('🔄 [LOGIN] Pushing to /onboarding (onboarding incomplete)');
        context.push('/onboarding');
      }
    } else {
      // Show Forui toast notification
      showFToast(
        context: context,
        alignment: FToastAlignment.bottomCenter,
        icon: Icon(FIcons.triangleAlert, color: context.theme.colors.destructive),
        title: const Text('Login Failed'),
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

    debugPrint('🔍 [LOGIN] Apple signin result - isSuccess: ${result.isSuccess}');
    debugPrint('   result.data: ${result.data}');

    if (result.isSuccess) {
      // Check if onboarding is complete and navigate accordingly
      final user = result.data;
      final onboardingCompleted = user?.onboardingCompleted ?? false;
      debugPrint('🔍 [LOGIN] User: ${user?.email}, onboardingCompleted=$onboardingCompleted');
      
      if (onboardingCompleted) {
        debugPrint('🔄 [LOGIN] Navigating to /home (onboarding complete)');
        context.go('/home');
      } else {
        debugPrint('🔄 [LOGIN] Pushing to /onboarding (onboarding incomplete)');
        context.push('/onboarding');
      }
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

    debugPrint('🔍 [LOGIN] Google signin result - isSuccess: ${result.isSuccess}');
    debugPrint('   result.data: ${result.data}');

    if (result.isSuccess) {
      // Check if onboarding is complete and navigate accordingly
      final user = result.data;
      final onboardingCompleted = user?.onboardingCompleted ?? false;
      debugPrint('🔍 [LOGIN] User: ${user?.email}, onboardingCompleted=$onboardingCompleted');
      
      if (onboardingCompleted) {
        debugPrint('🔄 [LOGIN] Navigating to /home (onboarding complete)');
        context.go('/home');
      } else {
        debugPrint('🔄 [LOGIN] Pushing to /onboarding (onboarding incomplete)');
        context.push('/onboarding');
      }
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
        title: const Text('Sign In'),
        prefixes: [
          FHeaderAction.back(onPress: () => context.pop()),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.standardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: AppConstants.largeGap),
                      // Email Field
                      FTextFormField.email(
                        control: FTextFieldControl.managed(controller: _emailController),
                        label: const Text('Email'),
                        hint: 'john@example.com',
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Email is required';
                          }
                          if (!value!.contains('@')) {
                            return 'Invalid email format';
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
                          if (value?.isEmpty ?? true) {
                            return 'Password is required';
                          }
                          if ((value?.length ?? 0) < AppConstants.minPasswordLength) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(height: AppConstants.largeGap),
                      // Sign In Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return FButton(
                            onPress: authProvider.isLoading ? null : () => _handleLogin(authProvider),
                            prefix: authProvider.isLoading ? const FCircularProgress() : null,
                            style: FButtonStyle.primary(),
                            child: Text(authProvider.isLoading ? 'Signing in...' : 'Sign In'),
                          );
                        },
                      ),
                      SizedBox(height: AppConstants.standardGap),
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
                      SizedBox(height: AppConstants.standardGap),
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
                              SizedBox(height: AppConstants.smallGap),
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
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.standardPadding, vertical: AppConstants.standardPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.foreground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: Text(
                      'Sign Up',
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
