import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'components/ui/workout_cards.dart';
import 'core/theme/heavyweight_theme.dart';
import 'widgetbook/stories/analytics_card_story.dart';
import 'widgetbook/stories/bottom_nav_story.dart';
import 'widgetbook/stories/calendar_header_story.dart';
import 'widgetbook/stories/dashboard_story.dart';
import 'widgetbook/stories/exercise_sheet_story.dart';
import 'widgetbook/stories/rest_timer_story.dart';
import 'widgetbook/stories/workout_assignment_story.dart';
import 'widgetbook/stories/completion_summary_story.dart';
import 'widgetbook/stories/settings_screen_story.dart';
import 'widgetbook/stories/settings_tile_story.dart';
import 'widgetbook/stories/settings_section_story.dart';
import 'widgetbook/stories/settings_premium_card_story.dart';
import 'widgetbook/stories/completion_summary_card_story.dart';
import 'widgetbook/stories/completion_metric_tile_story.dart';
import 'widgetbook/stories/completion_controls_story.dart';

void main() {
  runApp(const HeavyweightWidgetbook());
}

class HeavyweightWidgetbook extends StatelessWidget {
  const HeavyweightWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookFolder(
          name: 'Screens',
          children: [
            WidgetbookComponent(
              name: 'Workout Dashboard (mock)',
              useCases: [
                WidgetbookUseCase(
                  name: 'Preview',
                  builder: (_) => const DashboardMockScreen(),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Components',
          children: [
            buildRestTimerComponent(),
            buildDashboardComponent(),
            buildExerciseSheetComponent(),
            buildCalendarHeaderComponent(),
            buildAnalyticsCardComponent(),
            buildBottomNavComponent(),
            buildWorkoutAssignmentComponent(),
            WidgetbookFolder(
              name: 'Completion',
              children: [
                buildCompletionMetricTileComponent(),
                buildCompletionControlsComponent(),
                buildCompletionSummaryCardComponent(),
                buildCompletionSummaryComponent(),
              ],
            ),
            WidgetbookFolder(
              name: 'Settings',
              children: [
                buildSettingsTileComponent(),
                buildSettingsSectionComponent(),
                buildSettingsPremiumCardComponent(),
                buildSettingsScreenComponent(),
              ],
            ),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Dark',
              data: _buildDarkTheme(),
            ),
            WidgetbookTheme(
              name: 'Light',
              data: _buildLightTheme(),
            ),
          ],
        ),
        ViewportAddon([
          IosViewports.iPhone13ProMax,
          IosViewports.iPadAir4,
          MacosViewports.macbookPro,
        ]),
      ],
    );
  }
}

ThemeData _buildDarkTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: HeavyweightTheme.background,
    textTheme: base.textTheme.apply(
      fontFamily: 'Rubik',
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    canvasColor: HeavyweightTheme.background,
    cardColor: HeavyweightTheme.surface,
  );
}

ThemeData _buildLightTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF7F7FA),
    textTheme: base.textTheme.apply(
      fontFamily: 'Rubik',
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    canvasColor: Colors.white,
    cardColor: Colors.white,
  );
}

class DashboardMockScreen extends StatelessWidget {
  const DashboardMockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey Alex!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(
                    width: HeavyweightTheme.spacingSm,
                  ),
                  itemBuilder: (context, index) {
                    final isToday = index == 3;
                    return Container(
                      width: 48,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                            style: textTheme.labelMedium?.copyWith(
                              color: isToday ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${index + 4}',
                            style: textTheme.titleMedium?.copyWith(
                              color: isToday ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              const WeeklyProgressCard(
                completedWorkouts: 3,
                totalWorkouts: 4,
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    final crossAxisCount = isWide ? 2 : 1;
                    final childAspectRatio = isWide ? 1.1 : 2.6;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: HeavyweightTheme.spacingLg,
                        crossAxisSpacing: HeavyweightTheme.spacingLg,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        const titles = [
                          'Leg Day',
                          'Pull Machine',
                          'Push Day',
                          'Shoulders',
                        ];
                        const subtitles = [
                          '6 exercises',
                          '4 exercises',
                          '5 exercises',
                          '5 exercises',
                        ];
                        return WorkoutDayCard(
                          title: titles[index],
                          subtitle: subtitles[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingLg,
          vertical: HeavyweightTheme.spacingMd,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _NavIcon(icon: Icons.home),
                _NavIcon(icon: Icons.bar_chart),
                _NavIcon(icon: Icons.add_circle, isPrimary: true),
                _NavIcon(icon: Icons.playlist_add_check),
                _NavIcon(icon: Icons.person_outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    this.isPrimary = false,
  });

  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: isPrimary ? 38 : 26,
      color: isPrimary ? Colors.black : Colors.black38,
    );
  }
}
