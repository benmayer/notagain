/// Start Screen
///
/// Create and manage blocking rules for apps and websites
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Start Screen',
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Coming soon...',
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
