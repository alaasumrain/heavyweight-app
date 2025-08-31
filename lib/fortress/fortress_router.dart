import 'package:flutter/material.dart';
import 'mandate/mandate_screen.dart';
import 'mandate/calibration_protocol.dart';
import 'protocol/protocol_screen.dart';
import 'engine/mandate_engine.dart';

/// Fortress Router - Controls all navigation within the fortress system
/// This is the isolation layer that walls off legacy code
class FortressRouter {
  static const String mandateRoute = '/fortress/mandate';
  static const String protocolRoute = '/fortress/protocol';
  static const String calibrationRoute = '/fortress/calibration';
  
  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mandateRoute:
        return MaterialPageRoute(
          builder: (_) => const MandateScreen(),
          settings: settings,
        );
        
      case protocolRoute:
        final mandate = settings.arguments as WorkoutMandate?;
        if (mandate == null) {
          // No mandate provided, return to mandate screen
          return MaterialPageRoute(
            builder: (_) => const MandateScreen(),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ProtocolScreen(mandate: mandate),
          settings: settings,
        );
        
      case calibrationRoute:
        return MaterialPageRoute(
          builder: (_) => const CalibrationProtocolScreen(),
          settings: settings,
        );
        
      default:
        // Any unknown route returns to mandate
        return MaterialPageRoute(
          builder: (_) => const MandateScreen(),
        );
    }
  }
  
  /// Check if route is a fortress route
  static bool isFortressRoute(String? routeName) {
    if (routeName == null) return false;
    return routeName.startsWith('/fortress/');
  }
  
  /// Block all legacy routes
  static bool shouldBlockRoute(String? routeName) {
    if (routeName == null) return false;
    
    // List of legacy routes to block
    const blockedRoutes = [
      '/homePage',
      '/popularWorkout',
      '/workoutDetails',
      '/playSession',
      '/todayWorkoutPlan',
      '/recentWorkout',
      '/calanderPage',
      '/reportPage',
      '/profilePage',
      '/settingPage',
    ];
    
    return blockedRoutes.contains(routeName);
  }
}

/// Fortress Guard - Prevents access to legacy features
class FortressGuard extends StatelessWidget {
  final Widget child;
  final bool enableFortress;
  
  const FortressGuard({
    Key? key,
    required this.child,
    this.enableFortress = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (!enableFortress) {
      // Fortress disabled, show legacy app
      return child;
    }
    
    // Fortress enabled, show only fortress screens
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation to legacy screens
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (FortressRouter.isFortressRoute(currentRoute)) {
          // Allow back within fortress
          return true;
        }
        // Block back to legacy
        return false;
      },
      child: child,
    );
  }
}