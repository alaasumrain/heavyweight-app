import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';

class HWPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const HWPanel({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        color: HeavyweightTheme.surface,
        border: Border.all(color: HeavyweightTheme.secondary, width: 1),
      ),
      child: child,
    );
  }
}
