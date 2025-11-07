import 'package:flutter/widgets.dart';

/// Provides context about whether a shared shell already renders navigation chrome.
///
/// When present, child widgets can avoid rendering duplicate navigation elements.
class HeavyweightShellScope extends InheritedWidget {
  final bool hasShellNavigation;

  const HeavyweightShellScope({
    required this.hasShellNavigation,
    required super.child,
    super.key,
  });

  static HeavyweightShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HeavyweightShellScope>();
  }

  @override
  bool updateShouldNotify(covariant HeavyweightShellScope oldWidget) {
    return hasShellNavigation != oldWidget.hasShellNavigation;
  }
}
