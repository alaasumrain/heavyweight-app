import 'package:flutter/material.dart';
import 'logging.dart';

class HWRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _send(PageRoute<dynamic> route) {
    final name = route.settings.name ?? route.settings.toString();
    HWLog.event('nav_screen', data: {'screen': name});
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) _send(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PageRoute) _send(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

