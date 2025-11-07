import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/viewmodels/logbook_viewmodel.dart';
import '../../providers/logbook_viewmodel_provider.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../fortress/engine/storage/workout_repository_interface.dart';
import '../../core/logging.dart';

class TrainingLogScreen extends StatefulWidget {
  const TrainingLogScreen({super.key});

  static Widget withProvider() {
    return const LogbookViewModelProvider(
      child: TrainingLogScreen(),
    );
  }

  @override
  State<TrainingLogScreen> createState() => _TrainingLogScreenState();
}

class _TrainingLogScreenState extends State<TrainingLogScreen> {
  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HeavyweightTheme.spacingSm,
        vertical: HeavyweightTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
            color: HeavyweightTheme.secondary.withValues(alpha: 0.5)),
        color: HeavyweightTheme.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: HeavyweightTheme.labelSmall.copyWith(
              color: HeavyweightTheme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingXs),
          Text(
            value,
            style: HeavyweightTheme.h4.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionChip(String value, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HeavyweightTheme.spacingSm,
        vertical: HeavyweightTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        value,
        style: HeavyweightTheme.bodySmall.copyWith(
          color: HeavyweightTheme.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    HWLog.event('training_log_screen_init');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LogbookViewModel>().initialize();
      }
    });
  }

  @override
  void dispose() {
    HWLog.event('training_log_screen_dispose');
    super.dispose();
  }

  /// Refresh logbook data (for pull-to-refresh)
  Future<void> _refreshLogbook() async {
    await context.read<LogbookViewModel>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Training/Logbook');
    return Consumer<LogbookViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.error != null) {
          HWLog.event('training_log_state',
              data: {'state': 'error', 'error': viewModel.error.toString()});
          return _buildError(viewModel.error!);
        }

        if (viewModel.isLoading && !viewModel.hasSessions) {
          HWLog.event('training_log_state', data: {'state': 'loading'});
          return HeavyweightScaffold(
            title: 'LOGBOOK',
            body: const Center(
              child: CircularProgressIndicator(color: HeavyweightTheme.primary),
            ),
          );
        }

        HWLog.event('training_log_state', data: {
          'state': 'ready',
          'sessionCount': viewModel.sessions.length
        });

        return HeavyweightScaffold(
          title: 'LOGBOOK',
          body: RefreshIndicator(
            color: HeavyweightTheme.primary,
            backgroundColor: HeavyweightTheme.surface,
            onRefresh: _refreshLogbook,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HeavyweightTheme.spacingMd,
                vertical: HeavyweightTheme.spacingMd,
              ),
              children: [
                _buildStatsContainer(viewModel.stats),
                const SizedBox(height: HeavyweightTheme.spacingLg),
                if (viewModel.hasSessions) ...[
                  Text(
                    'SESSION_HISTORY:',
                    style: HeavyweightTheme.labelMedium.copyWith(
                      color: HeavyweightTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingMd),
                  ...viewModel.sessions
                      .map((session) => _buildSessionCard(session, viewModel)),
                ] else ...[
                  _buildEmptyState(),
                ],
                const SizedBox(height: HeavyweightTheme.spacingXl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsContainer(PerformanceStats stats) {
    return Container(
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        color: HeavyweightTheme.surface,
        border: Border.all(
            color: HeavyweightTheme.secondary.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE SNAPSHOT',
            style: HeavyweightTheme.labelMedium.copyWith(
              color: HeavyweightTheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Wrap(
            spacing: HeavyweightTheme.spacingSm,
            runSpacing: HeavyweightTheme.spacingSm,
            children: [
              _buildMetricTile('TOTAL SESSIONS', stats.workoutDays.toString()),
              _buildMetricTile('TOTAL SETS', stats.totalSets.toString()),
              _buildMetricTile(
                  'ADHERENCE', '${stats.mandateAdherence.toStringAsFixed(0)}%'),
              _buildMetricTile(
                  'TOTAL VOLUME', '${stats.totalVolume.toStringAsFixed(0)} KG'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(WorkoutSession session, LogbookViewModel viewModel) {
    final dayName = viewModel.getWorkoutDayName(session);
    final duration = viewModel.getSessionDuration(session);
    final exercises = viewModel.getExerciseSummary(session);
    final volume = viewModel.getSessionVolume(session);

    return InkWell(
      onTap: () => context.go('/session-detail', extra: session),
      child: Container(
        margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
        padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
        decoration: BoxDecoration(
          color: HeavyweightTheme.surface,
          border: Border.all(
              color: HeavyweightTheme.secondary.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(session.date),
                      style: HeavyweightTheme.labelSmall.copyWith(
                        color: HeavyweightTheme.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      dayName,
                      style: HeavyweightTheme.h4.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSessionChip(duration, HeavyweightTheme.secondary),
                    const SizedBox(height: HeavyweightTheme.spacingXs),
                    _buildSessionChip('${volume.toStringAsFixed(0)} KG',
                        HeavyweightTheme.primary),
                  ],
                ),
              ],
            ),
            const SizedBox(height: HeavyweightTheme.spacingSm),
            ...exercises.map((exerciseText) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: HeavyweightTheme.spacingXs),
                  child: Text(
                    exerciseText,
                    style: HeavyweightTheme.bodySmall.copyWith(
                      color: HeavyweightTheme.textSecondary,
                    ),
                  ),
                )),
            const SizedBox(height: HeavyweightTheme.spacingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOGGED SETS: ${session.sets.length}',
                  style: HeavyweightTheme.bodySmall.copyWith(
                    color: HeavyweightTheme.textSecondary,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: HeavyweightTheme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.secondary),
      ),
      child: Column(
        children: [
          Text(
            'NO_SESSIONS_RECORDED',
            style: HeavyweightTheme.h4.copyWith(
              color: HeavyweightTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingMd),
          Text(
            'Complete your first workout to see history here.',
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: HeavyweightTheme.spacingLg),
          CommandButton(
            text: 'GO TO ASSIGNMENT',
            variant: ButtonVariant.primary,
            onPressed: () => context.go('/app?tab=0'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return HeavyweightScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: HeavyweightTheme.error,
              size: 48,
            ),
            const SizedBox(height: HeavyweightTheme.spacingMd),
            Text(
              'ERROR',
              style: HeavyweightTheme.h3.copyWith(
                color: HeavyweightTheme.error,
              ),
            ),
            const SizedBox(height: HeavyweightTheme.spacingSm),
            Text(
              error,
              style: HeavyweightTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
