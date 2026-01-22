// Settings Screen
// 
// User settings and preferences management using pure Forui components

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
      header: FHeader.nested(
        title: const Text('Settings'),
        prefixes: [
          FHeaderAction.back(onPress: () => context.pop()),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return FTileGroup(
                          label: const Text('Account'),
                          children: [
                            FTile(
                              prefix: const Icon(FIcons.mail),
                              title: const Text('Email Address'),
                              details: Text(authProvider.user?.email ?? 'Not available'),
                              enabled: false,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Preferences Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Consumer<SettingsProvider>(
                      builder: (context, settingsProvider, _) {
                        return FTileGroup(
                          label: const Text('Preferences'),
                          children: [
                            FTile(
                              prefix: const Icon(FIcons.globe),
                              title: const Text('App Language'),
                              suffix: const Icon(FIcons.chevronRight),
                              onPress: () => _showLanguagePicker(context, settingsProvider),
                            ),
                            FTile(
                              prefix: const Icon(FIcons.smartphone),
                              title: const Text('Device Settings'),
                              suffix: const Icon(FIcons.chevronRight),
                              onPress: () => context.push('/settings/device-settings'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Display Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return FTileGroup(
                          label: const Text('Display'),
                          children: [
                            FTile(
                              prefix: const Icon(FIcons.monitor),
                              title: const Text('Dark Mode'),
                              suffix: FSwitch(
                                value: themeProvider.isDarkMode,
                                onChange: (value) {
                                  themeProvider.setDarkMode(value);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Help & Support Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FTileGroup(
                      label: const Text('Help & Support'),
                      children: [
                        FTile(
                          prefix: const Icon(FIcons.lifeBuoy),
                          title: const Text('Help & Support'),
                          suffix: const Icon(FIcons.chevronRight),
                          onPress: () => context.push('/settings/help-support'),
                        ),
                        FTile(
                          prefix: const Icon(FIcons.fileQuestionMark),
                          title: const Text('FAQs'),
                          suffix: const Icon(FIcons.chevronRight),
                          onPress: () => context.push('/settings/faqs'),
                        ),
                        FTile(
                          prefix: const Icon(FIcons.messageSquare),
                          title: const Text('Give Feedback'),
                          suffix: const Icon(FIcons.chevronRight),
                          onPress: () => context.push('/settings/feedback'),
                        ),
                      ],
                    ),
                  ),

                  // Terms & Policies Section
                  FTileGroup(
                    label: const Text('Terms & Policies'),
                    children: [
                      FTile(
                        prefix: const Icon(FIcons.fileText),
                        title: const Text('Terms of Service'),
                        suffix: const Icon(FIcons.chevronRight),
                        onPress: () => context.push('/settings/terms-of-service'),
                      ),
                      FTile(
                        prefix: const Icon(FIcons.shield),
                        title: const Text('Privacy Policy'),
                        suffix: const Icon(FIcons.chevronRight),
                        onPress: () => context.push('/settings/privacy-policy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FDivider(),
            ),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GestureDetector(
                  onTap: () {
                    settingsProvider.setLanguage(lang.key);
                    Navigator.pop(context);
                  },
                  child: FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang.value,
                            style: context.theme.typography.base.copyWith(
                              color: context.theme.colors.foreground,
                            ),
                          ),
                          if (settingsProvider.language == lang.key)
                            Icon(
                              FIcons.check,
                              color: context.theme.colors.primary,
                            ),
                        ],
                      ),
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

