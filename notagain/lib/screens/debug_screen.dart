import 'package:flutter/cupertino.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🧪 [DEBUG] DebugScreen built');
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Debug Screen'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('This is a plain CupertinoPageScaffold'),
              const SizedBox(height: 20),
              const Text('Try swiping from left edge to go back'),
              const SizedBox(height: 40),
              CupertinoButton.filled(
                onPressed: () {
                  debugPrint('🧪 [DEBUG] Back button tapped');
                  Navigator.of(context).pop();
                },
                child: const Text('Tap to Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

