/// Main Layout
/// 
/// Shared layout containing the Scaffold, header, and bottom navigation
/// All authenticated screens are wrapped with this layout
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    required this.child,
    required this.currentRoute,
    super.key,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getIndexFromRoute(widget.currentRoute);
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _selectedIndex = _getIndexFromRoute(widget.currentRoute);
    }
  }

  int _getIndexFromRoute(String route) {
    if (route.startsWith('/home')) return 0;
    if (route.startsWith('/start')) return 1;
    if (route.startsWith('/profile')) return 2;
    return 0;
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/start');
      case 2:
        context.go('/profile');
    }
  }

  FHeader _buildHeader() {
    switch (_selectedIndex) {
      case 0:
        return const FHeader(title: Text('Home'));
      case 1:
        return const FHeader(title: Text('Start'));
      case 2:
        return FHeader(
          title: const Text('Profile'),
          suffixes: [
            FHeaderAction(
              icon: const Icon(FIcons.settings),
              onPress: () => context.push('/settings'),
            ),
          ],
        );
      default:
        return const FHeader(title: Text('Home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: _buildHeader(),
      footer: FBottomNavigationBar(
        index: _selectedIndex,
        onChange: _onNavItemTapped,
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(FIcons.house),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.squarePlus),
            label: Text('Start'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.user),
            label: Text('Profile'),
          ),
        ],
      ),
      child: widget.child,
    );
  }
}
