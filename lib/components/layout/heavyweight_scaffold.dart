import 'package:flutter/material.dart';
import '../ui/system_banner.dart';
import '../ui/navigation_bar.dart';
import '../../core/theme/heavyweight_theme.dart';

/// Standard scaffold for all HEAVYWEIGHT screens
/// Ensures consistent layout and spacing
class HeavyweightScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget body;
  final int? navIndex;
  final bool showBanner;
  final bool showNavigation;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  
  const HeavyweightScaffold({
    Key? key,
    this.title,
    this.subtitle,
    required this.body,
    this.navIndex,
    this.showBanner = true,
    this.showNavigation = false,
    this.floatingActionButton,
    this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeavyweightTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            if (showBanner || title != null)
              Padding(
                padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
                child: Column(
                  children: [
                    if (showBanner) const SystemBanner(),
                    if (showBanner && title != null) 
                      const SizedBox(height: HeavyweightTheme.spacingXxxl),
                    
                    if (title != null) ...[
                      Text(
                        title!,
                        style: HeavyweightTheme.h2,
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: HeavyweightTheme.spacingSm),
                        Text(
                          subtitle!,
                          style: HeavyweightTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            
            // Body content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HeavyweightTheme.spacingLg,
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
  }
}

