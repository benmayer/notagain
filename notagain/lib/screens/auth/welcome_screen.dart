/// Welcome Screen
///
/// Initial screen shown to unauthenticated users
/// Provides options to Sign In or Get Started (Sign Up)
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Column(
        children: [
          // Top spacing
          const SizedBox(height: 48),
          // App Logo & Title
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.theme.colors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(
                        FIcons.stone,
                        color: context.theme.colors.primaryForeground,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NotAgain',
                    style: context.theme.typography.xl.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take control of your screen time',
                    style: context.theme.typography.base.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FButton(
                  onPress: () => context.go('/signup'),
                  style: FButtonStyle.primary(),
                  child: const Text('Get Started'),
                ),
                const SizedBox(height: 12),
                FButton(
                  onPress: () => context.go('/login'),
                  style: FButtonStyle.secondary(),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
