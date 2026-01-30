/// Settings Stubs
/// 
/// Placeholder screens for settings navigation stubs
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

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
    return FScaffold(
      header: FHeader.nested(
        title: Text(title),
        prefixes: [
          FHeaderAction.back(onPress: () => context.pop()),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.theme.typography.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
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
          icon: FIcons.smartphone,
        );
}

class HelpSupportScreen extends _SettingsStubScreen {
  const HelpSupportScreen()
      : super(
          title: 'Help & Support',
          description: 'Coming soon',
          icon: FIcons.lifeBuoy,
        );
}

class FAQsScreen extends _SettingsStubScreen {
  const FAQsScreen()
      : super(
          title: 'FAQs',
          description: 'Coming soon',
          icon: FIcons.fileQuestionMark,
        );
}

class FeedbackScreen extends _SettingsStubScreen {
  const FeedbackScreen()
      : super(
          title: 'Give Feedback',
          description: 'Coming soon',
          icon: FIcons.messageSquare,
        );
}

class TermsOfServiceScreen extends _SettingsStubScreen {
  const TermsOfServiceScreen()
      : super(
          title: 'Terms of Service',
          description: 'Coming soon',
          icon: FIcons.file,
        );
}

class PrivacyPolicyScreen extends _SettingsStubScreen {
  const PrivacyPolicyScreen()
      : super(
          title: 'Privacy Policy',
          description: 'Coming soon',
          icon: FIcons.shield,
        );
}
