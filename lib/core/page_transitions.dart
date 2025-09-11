import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Minimal page transitions used by the app
class HeavyweightPageTransitions {
  /// Fade transition for non-directional navigation
  static Page<T> fadeTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  /// No transition for immediate navigation
  static Page<T> noTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return NoTransitionPage<T>(
      key: state.pageKey,
      child: child,
    );
  }
}


