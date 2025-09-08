import 'package:flutter/material.dart';

/// Warning stripes component - inspired by industrial/construction warning patterns
/// Perfect for critical states, system alerts, and attention-grabbing UI elements
class WarningStripes extends StatelessWidget {
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final double stripeWidth;
  final String? text;
  final TextStyle? textStyle;
  final bool animated;
  final EdgeInsetsGeometry? padding;
  
  const WarningStripes({
    Key? key,
    this.height = 40.0,
    this.primaryColor = const Color(0xFFFFD700), // Gold/Yellow
    this.secondaryColor = const Color(0xFF000000), // Black
    this.stripeWidth = 20.0,
    this.text,
    this.textStyle,
    this.animated = false,
    this.padding,
  }) : super(key: key);
  
  /// Factory for standard warning stripes (yellow/black)
  factory WarningStripes.warning({
    double height = 40.0,
    String? text,
    TextStyle? textStyle,
    bool animated = false,
    EdgeInsetsGeometry? padding,
  }) {
    return WarningStripes(
      height: height,
      primaryColor: const Color(0xFFFFD700), // Gold
      secondaryColor: const Color(0xFF000000), // Black
      text: text,
      textStyle: textStyle,
      animated: animated,
      padding: padding,
    );
  }
  
  /// Factory for danger stripes (red/black)
  factory WarningStripes.danger({
    double height = 40.0,
    String? text,
    TextStyle? textStyle,
    bool animated = false,
    EdgeInsetsGeometry? padding,
  }) {
    return WarningStripes(
      height: height,
      primaryColor: const Color(0xFFFF4444), // Red
      secondaryColor: const Color(0xFF000000), // Black
      text: text,
      textStyle: textStyle,
      animated: animated,
      padding: padding,
    );
  }
  
  /// Factory for construction/caution stripes (orange/black)
  factory WarningStripes.caution({
    double height = 40.0,
    String? text,
    TextStyle? textStyle,
    bool animated = false,
    EdgeInsetsGeometry? padding,
  }) {
    return WarningStripes(
      height: height,
      primaryColor: const Color(0xFFFF8C00), // Dark orange
      secondaryColor: const Color(0xFF000000), // Black
      text: text,
      textStyle: textStyle,
      animated: animated,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget stripesWidget = Container(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StripesPainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          stripeWidth: stripeWidth,
        ),
        child: text != null
            ? Container(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.center,
                child: Text(
                  text!,
                  style: textStyle ?? TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
      ),
    );
    
    if (animated) {
      return _AnimatedStripes(child: stripesWidget);
    }
    
    return stripesWidget;
  }
}

/// Custom painter for diagonal warning stripes
class _StripesPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double stripeWidth;
  
  _StripesPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.stripeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Fill background with secondary color
    paint.color = secondaryColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw diagonal stripes with primary color
    paint.color = primaryColor;
    
    final double diagonalLength = size.width + size.height;
    final double stripeSpacing = stripeWidth * 2;
    
    for (double x = -size.height; x < diagonalLength; x += stripeSpacing) {
      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x + stripeWidth, 0);
      path.lineTo(x + stripeWidth + size.height, size.height);
      path.lineTo(x + size.height, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated wrapper for moving stripes effect
class _AnimatedStripes extends StatefulWidget {
  final Widget child;
  
  const _AnimatedStripes({required this.child});
  
  @override
  State<_AnimatedStripes> createState() => _AnimatedStripesState();
}

class _AnimatedStripesState extends State<_AnimatedStripes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 40.0, // Move by stripe width * 2
    ).animate(_controller);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}








