import 'package:flutter/cupertino.dart';

/// Custom CupertinoPageRoute that properly exposes the swipe-back gesture
/// This allows users to swipe from the left edge to navigate back, following iOS UX patterns
class CupertinoPageRouteWithGesture<T> extends CupertinoPageRoute<T> {
  CupertinoPageRouteWithGesture({
    required super.builder,
    super.title,
    super.settings,
  });

  @override
  bool get popGestureEnabled => true;
}

/// Custom GoRouter page that uses CupertinoPageRoute with proper gesture support
class CupertinoPageWithGesture<T> extends Page<T> {
  final Widget child;
  final String? title;

  const CupertinoPageWithGesture({
    required this.child,
    this.title,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return CupertinoPageRouteWithGesture<T>(
      builder: (context) => child,
      title: title,
      settings: this,
    );
  }
}
