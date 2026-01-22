// Home Screen
// 
// Main dashboard after authentication

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import '../start/start_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    PlaceholderScreen(title: 'Home'),
    StartScreen(),
    ProfileScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<FHeader> _buildHeaders(BuildContext context) {
    return [
      const FHeader(title: Text('Home')),
      const FHeader(title: Text('Start')),
      FHeader(
        title: const Text('Profile'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(Icons.settings),
            onPress: () => context.push('/settings'),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final headers = _buildHeaders(context);
    return FScaffold(
      header: headers[_selectedIndex],
      footer: FBottomNavigationBar(
        index: _selectedIndex,
        onChange: _onNavItemTapped,
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: Text('Start'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
      ),
      child: _screens[_selectedIndex],
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$title Screen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Coming soon...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
