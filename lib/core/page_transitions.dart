import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for HEAVYWEIGHT app
/// Creates smooth, directional transitions that feel like a carousel
class HeavyweightPageTransitions {
  
  /// Slide transition that respects navigation direction
  /// Left/right based on tab index for carousel feel
  static Page<T> slideTransition<T extends Object?>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    int? fromIndex,
    int? toIndex,
  }) {
    // Determine slide direction based on navigation
    SlideDirection direction = SlideDirection.none;
    
    if (fromIndex != null && toIndex != null) {
      if (toIndex > fromIndex) {
        direction = SlideDirection.leftToRight; // Going forward
      } else if (toIndex < fromIndex) {
        direction = SlideDirection.rightToLeft; // Going backward
      }
    }
    
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSlideTransition(
          animation, 
          secondaryAnimation, 
          child, 
          direction,
        );
      },
    );
  }
  
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
  
  static Widget _buildSlideTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    SlideDirection direction,
  ) {
    if (direction == SlideDirection.none) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
        child: child,
      );
    }
    
    // Enhanced curve for smoother carousel feel
    final curve = CurveTween(curve: Curves.easeInOutCubic);
    
    // Primary slide animation with slight scale effect
    final slideAnimation = Tween<Offset>(
      begin: direction == SlideDirection.leftToRight 
          ? const Offset(1.0, 0.0)  // Slide in from right
          : const Offset(-1.0, 0.0), // Slide in from left
      end: Offset.zero,
    ).animate(curve.animate(animation));
    
    // Scale animation for depth effect
    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(curve.animate(animation));
    
    // Secondary slide animation (for the outgoing page)
    final secondarySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: direction == SlideDirection.leftToRight
          ? const Offset(-0.3, 0.0)  // Partial slide out to left
          : const Offset(0.3, 0.0),  // Partial slide out to right
    ).animate(curve.animate(secondaryAnimation));
    
    // Secondary scale animation
    final secondaryScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(curve.animate(secondaryAnimation));
    
    return Stack(
      children: [
        // Outgoing page with scale and slide
        SlideTransition(
          position: secondarySlideAnimation,
          child: ScaleTransition(
            scale: secondaryScaleAnimation,
            child: child,
          ),
        ),
        // Incoming page with scale and slide
        SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        ),
      ],
    );
  }
}

enum SlideDirection {
  leftToRight,
  rightToLeft,
  none,
}

/// Helper to get navigation direction based on route names
class NavigationHelper {
  static const Map<String, int> _routeIndices = {
    '/assignment': 0,
    '/training-log': 1,
    '/settings': 2,
  };
  
  static int? getRouteIndex(String route) {
    return _routeIndices[route];
  }
  
  static SlideDirection getDirection(String? fromRoute, String? toRoute) {
    if (fromRoute == null || toRoute == null) return SlideDirection.none;
    
    final fromIndex = getRouteIndex(fromRoute);
    final toIndex = getRouteIndex(toRoute);
    
    if (fromIndex == null || toIndex == null) return SlideDirection.none;
    
    if (toIndex > fromIndex) return SlideDirection.leftToRight;
    if (toIndex < fromIndex) return SlideDirection.rightToLeft;
    
    return SlideDirection.none;
  }
}



