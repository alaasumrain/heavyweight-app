import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wrapper that adds swipe navigation to screens
/// Creates carousel-like navigation between main app screens
class SwipeableScreen extends StatefulWidget {
  final Widget child;
  final String? previousRoute;
  final String? nextRoute;
  final bool enableSwipe;

  const SwipeableScreen({
    Key? key,
    required this.child,
    this.previousRoute,
    this.nextRoute,
    this.enableSwipe = true,
  }) : super(key: key);

  @override
  State<SwipeableScreen> createState() => _SwipeableScreenState();
}

class _SwipeableScreenState extends State<SwipeableScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _dragDistance = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurveTween(curve: Curves.easeInOutCubic).animate(_animationController));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableSwipe) {
      return widget.child;
    }

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_dragDistance + _slideAnimation.value, 0),
            child: widget.child,
          );
        },
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _animationController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragDistance += details.delta.dx;
      
      // Limit drag distance to prevent over-scrolling
      _dragDistance = _dragDistance.clamp(-150.0, 150.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    _isDragging = false;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25; // 25% of screen width
    
    // Determine if swipe was significant enough
    if (_dragDistance.abs() > threshold) {
      if (_dragDistance > 0 && widget.previousRoute != null) {
        // Swiped right - go to previous screen
        _navigateWithAnimation(widget.previousRoute!, true);
      } else if (_dragDistance < 0 && widget.nextRoute != null) {
        // Swiped left - go to next screen
        _navigateWithAnimation(widget.nextRoute!, false);
      } else {
        _snapBack();
      }
    } else {
      _snapBack();
    }
  }

  void _navigateWithAnimation(String route, bool isGoingBack) {
    // Animate to completion
    _slideAnimation = Tween<double>(
      begin: _dragDistance,
      end: isGoingBack ? MediaQuery.of(context).size.width : -MediaQuery.of(context).size.width,
    ).animate(CurveTween(curve: Curves.easeInOutCubic).animate(_animationController));

    _animationController.forward().then((_) {
      context.go(route);
      _resetAnimation();
    });
  }

  void _snapBack() {
    // Animate back to center
    _slideAnimation = Tween<double>(
      begin: _dragDistance,
      end: 0,
    ).animate(CurveTween(curve: Curves.easeInOutCubic).animate(_animationController));

    _animationController.forward().then((_) {
      _resetAnimation();
    });
  }

  void _resetAnimation() {
    _dragDistance = 0;
    _animationController.reset();
    _slideAnimation = Tween<double>(begin: 0, end: 0).animate(_animationController);
  }
}

/// Helper class to define swipe navigation routes
class SwipeNavigation {
  static const Map<String, SwipeRoutes> _routes = {
    '/assignment': SwipeRoutes(
      previous: null,
      next: '/training-log',
    ),
    '/training-log': SwipeRoutes(
      previous: '/assignment',
      next: '/settings',
    ),
    '/settings': SwipeRoutes(
      previous: '/training-log',
      next: null,
    ),
  };

  static SwipeRoutes? getRoutes(String currentRoute) {
    return _routes[currentRoute];
  }
}

class SwipeRoutes {
  final String? previous;
  final String? next;

  const SwipeRoutes({
    this.previous,
    this.next,
  });
}
