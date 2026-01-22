/// Settings Stubs
/// 
/// Placeholder screens for settings navigation stubs
library;

import 'package:flutter/material.dart';

class _SettingsStubScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _SettingsStubScreen({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceSettingsScreen extends _SettingsStubScreen {
  const DeviceSettingsScreen()
      : super(
          title: 'Device Settings',
          description: 'Coming soon',
          icon: Icons.phone_iphone,
        );
}

class HelpSupportScreen extends _SettingsStubScreen {
  const HelpSupportScreen()
      : super(
          title: 'Help & Support',
          description: 'Coming soon',
          icon: Icons.help_outline,
        );
}

class FAQsScreen extends _SettingsStubScreen {
  const FAQsScreen()
      : super(
          title: 'FAQs',
          description: 'Coming soon',
          icon: Icons.question_answer_outlined,
        );
}

class FeedbackScreen extends _SettingsStubScreen {
  const FeedbackScreen()
      : super(
          title: 'Give Feedback',
          description: 'Coming soon',
          icon: Icons.feedback_outlined,
        );
}

class TermsOfServiceScreen extends _SettingsStubScreen {
  const TermsOfServiceScreen()
      : super(
          title: 'Terms of Service',
          description: 'Coming soon',
          icon: Icons.description_outlined,
        );
}

class PrivacyPolicyScreen extends _SettingsStubScreen {
  const PrivacyPolicyScreen()
      : super(
          title: 'Privacy Policy',
          description: 'Coming soon',
          icon: Icons.privacy_tip_outlined,
        );
}
