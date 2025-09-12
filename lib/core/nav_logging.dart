import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global navigator key and observer for deep logging of navigation events.
class NavLogging {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final LoggingNavigatorObserver observer = LoggingNavigatorObserver();
}

class LoggingNavigatorObserver extends NavigatorObserver {
  void _log(String msg) {
    if (kDebugMode) debugPrint('🧭 NAV: $msg');
  }

  void _dumpStack(NavigatorState? nav) {
    final stack = <String>[];
    nav?.popUntil((route) {
      stack.add('[${route.settings.name ?? route.settings.toString()}] ${route.runtimeType}');
      return true;
    });
    _log('STACK: ${stack.join(' -> ')}');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _log('didPush: ${route.settings.name ?? route.settings} (prev: ${previousRoute?.settings.name ?? previousRoute?.settings})');
    _dumpStack(navigator);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _log('didPop: ${route.settings.name ?? route.settings} -> ${previousRoute?.settings.name ?? previousRoute?.settings}');
    _dumpStack(navigator);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('didRemove: ${route.settings.name ?? route.settings}');
    _dumpStack(navigator);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('didReplace: ${oldRoute?.settings.name ?? oldRoute?.settings} -> ${newRoute?.settings.name ?? newRoute?.settings}');
    _dumpStack(navigator);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    _log('didStartUserGesture on ${route.settings.name ?? route.settings}');
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    _log('didStopUserGesture');
  }
}

