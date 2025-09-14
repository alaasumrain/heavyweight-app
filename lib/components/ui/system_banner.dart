import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';

class SystemBanner extends StatelessWidget {
  const SystemBanner({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: HeavyweightTheme.spacingLg),
      child: Text(
        'HEAVYWEIGHT',
        textAlign: TextAlign.center,
        style: HeavyweightTheme.h4,
      ),
    );
  }
}