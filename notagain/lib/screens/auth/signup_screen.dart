/// Sign Up Screen
/// 
/// Handles new user registration with email, password, and name
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms')),
      );
      return;
    }

    final response = await authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (response.isSuccess && response.user != null) {
      // Navigate to home screen via go_router
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error ?? 'Signup failed')),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 16),

                    // Password Field
                    FTextFormField.password(
                      control: FTextFieldControl.managed(controller: _passwordController),
                      label: const Text('Password'),
                      hint: 'Enter your password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
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
                    const SizedBox(height: 24),

                    // Terms Agreement Checkbox
                    FCheckbox(
                      value: _agreedToTerms,
                      onChange: (value) {
                        setState(() => _agreedToTerms = value);
                      },
                      label: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: context.theme.typography.sm.copyWith(
                          color: context.theme.colors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: context.theme.colors.border,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const SizedBox(height: 24),

                    // Social Auth Buttons
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FButton(
                              onPress: authProvider.isLoading ? null : () => authProvider.signInWithApple(),
                              prefix: authProvider.isLoading ? const FCircularProgress() : const Icon(FIcons.apple),
                              style: FButtonStyle.outline(),
                              child: const Text('Continue with Apple'),
                            ),
                            const SizedBox(height: 12),
                            FButton(
                              onPress: authProvider.isLoading ? null : () => authProvider.signInWithGoogle(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
