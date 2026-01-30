// Home Screen
// 
// Main dashboard after authentication

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../core/logging/app_logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.info('HomeScreen initialized', tag: 'Navigation');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Home Screen',
                  style: context.theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colors.foreground,
                  ),
                ),
                Text(
                  'Coming soon...',
                  style: context.theme.typography.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
