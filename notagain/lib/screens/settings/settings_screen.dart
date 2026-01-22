// Settings Screen
// 
// User settings and preferences management

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleLogout(BuildContext context) {
    showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        title: const Text('Sign Out'),
        body: const Text('Are you sure you want to sign out?'),
        actions: [
          FButton(
            onPress: () => Navigator.pop(context),
            style: FButtonStyle.outline(),
            child: const Text('Cancel'),
          ),
          FButton(
            onPress: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              await Future.delayed(const Duration(milliseconds: 100));
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: FButtonStyle.destructive(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              
              // Account Section
              _SettingsSection(
                title: 'Account',
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return _SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email Address',
                        subtitle: authProvider.user?.email ?? 'Not available',
                        enabled: false,
                      );
                    },
                  ),
                ],
              ),

              // Preferences Section
              _SettingsSection(
                title: 'Preferences',
                children: [
                  Consumer<SettingsProvider>(
                    builder: (context, settingsProvider, _) {
                      return _SettingsTile(
                        icon: Icons.language,
                        title: 'App Language',
                        subtitle: settingsProvider.language,
                        onTap: () => _showLanguagePicker(context, settingsProvider),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings/device-settings'),
                    child: const _SettingsTile(
                      icon: Icons.phone_iphone,
                      title: 'Device Settings',
                      subtitle: 'Configure device preferences',
                    ),
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return _SettingsTile(
                        icon: Icons.brightness_6,
                        title: 'Display',
                        subtitle: themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                        onTap: () {
                          themeProvider.toggleTheme();
                        },
                        trailing: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Help & Support Section
              _SettingsSection(
                title: 'Help & Support',
                children: [
                  GestureDetector(
                    onTap: () => context.push('/settings/help-support'),
                    child: const _SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help with the app',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings/faqs'),
                    child: const _SettingsTile(
                      icon: Icons.question_answer_outlined,
                      title: 'FAQs',
                      subtitle: 'Frequently asked questions',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings/feedback'),
                    child: const _SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: 'Give Feedback',
                      subtitle: 'Share your thoughts with us',
                    ),
                  ),
                ],
              ),

              // Terms & Policies Section
              _SettingsSection(
                title: 'Terms & Policies',
                children: [
                  GestureDetector(
                    onTap: () => context.push('/settings/terms-of-service'),
                    child: const _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings/privacy-policy'),
                    child: const _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                    ),
                  ),
                ],
              ),

                ],
              ),
            ),
            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: FButton(
                onPress: () => _handleLogout(context),
                style: FButtonStyle.destructive(),
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        title: const Text('Select Language'),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: settingsProvider.availableLanguages.map((lang) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  onTap: () {
                    settingsProvider.setLanguage(lang.key);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: settingsProvider.language == lang.key
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lang.value),
                        if (settingsProvider.language == lang.key)
                          Icon(Icons.check, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          FButton(
            child: const Text('Done'),
            onPress: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        FCard.raw(
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: enabled && onTap != null
            ? colorScheme.surface.withValues(alpha: 0.5)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? colorScheme.primary : colorScheme.outline,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: enabled ? null : colorScheme.outline,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing ??
                (onTap != null && enabled
                    ? Icon(
                        Icons.chevron_right,
                        color: colorScheme.outline,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
