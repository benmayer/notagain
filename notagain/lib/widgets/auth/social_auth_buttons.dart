/// Social Auth Buttons Widget
/// 
/// Reusable buttons for Apple and Google authentication

import 'package:flutter/material.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onAppleTap;
  final VoidCallback onGoogleTap;
  final bool isLoading;

  const SocialAuthButtons({
    super.key,
    required this.onAppleTap,
    required this.onGoogleTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Apple Sign In
        OutlinedButton.icon(
          onPressed: isLoading ? null : onAppleTap,
          icon: const Icon(Icons.apple),
          label: const Text('Sign in with Apple'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Google Sign In
        OutlinedButton.icon(
          onPressed: isLoading ? null : onGoogleTap,
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Sign in with Google'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
