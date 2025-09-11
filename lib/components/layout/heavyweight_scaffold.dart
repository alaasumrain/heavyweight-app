import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../ui/navigation_bar.dart';
import '../ui/heavyweight_header.dart';
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
  
  const HeavyweightScaffold({
    Key? key,
    this.title,
    this.subtitle,
    required this.body,
    this.navIndex,
    this.showNavigation = false,
    this.showBackButton = true,
    this.fallbackRoute = '/',
    this.floatingActionButton,
    this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🏗️ HeavyweightScaffold: build() START - title=$title, showBackButton=$showBackButton');
      debugPrint('🏗️ HeavyweightScaffold: context=$context');
      debugPrint('🏗️ HeavyweightScaffold: About to create Scaffold with background=${HeavyweightTheme.background}');
    }
    HWLog.event('scaffold_build', data: {
      'title': title ?? '',
      'showBackButton': showBackButton,
      'showNavigation': showNavigation,
    });
    
    try {
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
            
            // Body content with reduced horizontal padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HeavyweightTheme.spacingMd, // Reduced from spacingLg
                ),
                child: body,
              ),
            ),
          ],
        ),
        ),
        bottomNavigationBar: showNavigation && navIndex != null
            ? HeavyweightNavigationBar(currentIndex: navIndex!)
            : null,
        floatingActionButton: floatingActionButton,
      );
      
      if (kDebugMode) {
        debugPrint('🏗️ HeavyweightScaffold: build() SUCCESS - Scaffold created and returned');
      }
      
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








