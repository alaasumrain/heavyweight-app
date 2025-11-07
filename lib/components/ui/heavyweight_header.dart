import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';

/// Consistent header for all HEAVYWEIGHT screens
/// Combines title and back button on the same line
class HeavyweightHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final String? fallbackRoute;
  final List<Widget>? actions;

  const HeavyweightHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    this.fallbackRoute = '/',
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main header row with back button and title
        Row(
          children: [
            // Back button on the left
            if (showBackButton)
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: HeavyweightTheme.primary),
                onPressed: () {
                  final router = GoRouter.of(context);
                  if (router.canPop()) {
                    router.pop();
                  } else if (fallbackRoute != null) {
                    router.go(fallbackRoute!);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              const SizedBox(
                  width: 48), // Maintain alignment when no back button

            // Title in the center with improved styling
            Expanded(
              child: Text(
                'HEAVYWEIGHT', // Always show HEAVYWEIGHT
                style: HeavyweightTheme.h1.copyWith(
                  fontSize: 28, // Slightly smaller for better fit
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Actions or spacer on the right
            if (actions != null && actions!.isNotEmpty)
              Row(children: actions!)
            else
              const SizedBox(width: 48), // Balance the back button space
          ],
        ),

        // Subtitle - show title parameter as subtitle, or subtitle if provided
        if (title != null || subtitle != null) ...[
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Text(
            title ?? subtitle ?? '',
            style: HeavyweightTheme.bodyMedium.copyWith(
              color: HeavyweightTheme.textSecondary,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
