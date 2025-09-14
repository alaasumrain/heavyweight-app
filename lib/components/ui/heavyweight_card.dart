import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';

enum CardVariant { 
  standard, 
  active, 
  accent, 
  error 
}

/// Consistent card component for all content blocks
class HeavyweightCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool animated;
  
  const HeavyweightCard({
    super.key,
    required this.child,
    this.variant = CardVariant.standard,
    this.onTap,
    this.padding,
    this.animated = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final decoration = _getDecoration();
    final effectivePadding = padding ?? const EdgeInsets.all(HeavyweightTheme.spacingLg);
    
    Widget card = Container(
      width: double.infinity,
      padding: effectivePadding,
      decoration: decoration,
      child: child,
    );
    
    if (animated) {
      card = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: effectivePadding,
        decoration: decoration,
        child: child,
      );
    }
    
    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }
  
  BoxDecoration _getDecoration() {
    switch (variant) {
      case CardVariant.standard:
        return HeavyweightTheme.cardDecoration;
      case CardVariant.active:
        return HeavyweightTheme.cardDecorationActive;
      case CardVariant.accent:
        return HeavyweightTheme.accentCardDecoration;
      case CardVariant.error:
        return BoxDecoration(
          color: HeavyweightTheme.errorSurface.withOpacity(0.1),
          border: Border.all(color: HeavyweightTheme.error),
        );
    }
  }
}










