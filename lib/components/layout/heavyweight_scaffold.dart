import 'package:flutter/material.dart';
import '../ui/navigation_bar.dart';
import '../ui/heavyweight_header.dart';
import '../navigation/heavyweight_shell_scope.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../core/logging.dart';

/// Standard scaffold for all HEAVYWEIGHT screens
/// Ensures consistent layout and spacing
class HeavyweightScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget body;
  final int? navIndex;
  final bool showNavigation;
  final bool showBackButton;
  final String? fallbackRoute;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final EdgeInsetsGeometry? bodyPadding;

  const HeavyweightScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.body,
    this.navIndex,
    this.showNavigation = false,
    this.showBackButton = true,
    this.fallbackRoute = '/',
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bodyPadding,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Quiet build; avoid verbose logging in production

    try {
      final shellScope = HeavyweightShellScope.maybeOf(context);
      final shouldShowNavigation = showNavigation &&
          navIndex != null &&
          shellScope?.hasShellNavigation != true;

      final scaffold = Scaffold(
        backgroundColor: HeavyweightTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header section - always show HEAVYWEIGHT header
              Padding(
                padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                child: HeavyweightHeader(
                  title: title, // This will be shown as subtitle
                  subtitle: subtitle,
                  showBackButton: showBackButton,
                  fallbackRoute: fallbackRoute,
                  actions: actions,
                ),
              ),

              // Body content adapts across breakpoints
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final hasCustomPadding = bodyPadding != null;
                    final resolvedPadding = bodyPadding ?? EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth >= HeavyweightTheme.breakpointTablet
                          ? HeavyweightTheme.spacingXl
                          : HeavyweightTheme.spacingMd,
                    );

                    Widget content = Padding(
                      padding: resolvedPadding,
                      child: body,
                    );

                    final shouldConstrainWidth = !hasCustomPadding &&
                        constraints.maxWidth >= HeavyweightTheme.breakpointTablet;

                    if (shouldConstrainWidth) {
                      const maxWidth = HeavyweightTheme.contentMaxWidth;
                      content = Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: content,
                        ),
                      );
                    }

                    return content;
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: shouldShowNavigation
            ? HeavyweightNavigationBar(currentIndex: navIndex!)
            : null,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );

      return scaffold;
    } catch (e) {
      // Fallback UI in case of errors
      debugPrint('Scaffold build error: $e');
      HWLog.event('scaffold_build_error', data: {
        'error': e.toString(),
        'title': title ?? '',
      });
      return Scaffold(
        backgroundColor: HeavyweightTheme.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: HeavyweightTheme.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'UI ERROR',
                  style: HeavyweightTheme.h2.copyWith(
                    color: HeavyweightTheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please restart the app',
                  style: HeavyweightTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
