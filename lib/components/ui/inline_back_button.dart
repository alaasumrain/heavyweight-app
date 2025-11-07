import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';

/// Simple inline back button with fallback route
class InlineBackButton extends StatelessWidget {
  final String fallbackRoute;
  const InlineBackButton({super.key, this.fallbackRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: HeavyweightTheme.primary),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(fallbackRoute);
          }
        },
      ),
    );
  }
}
