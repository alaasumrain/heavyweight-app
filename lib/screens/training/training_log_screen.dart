import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/viewmodels/logbook_viewmodel.dart';
import '../../providers/logbook_viewmodel_provider.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../fortress/engine/storage/workout_repository_interface.dart';
import '../../core/logging.dart';

class TrainingLogScreen extends StatefulWidget {
  const TrainingLogScreen({Key? key}) : super(key: key);
  
  static Widget withProvider() {
    return const LogbookViewModelProvider(
      child: TrainingLogScreen(),
    );
  }
  
  @override
  State<TrainingLogScreen> createState() => _TrainingLogScreenState();
}

class _TrainingLogScreenState extends State<TrainingLogScreen> {
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogbookViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Training/Logbook');
    return Consumer<LogbookViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          HWLog.event('training_log_state', data: {'state': 'loading'});
          return HeavyweightScaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: HeavyweightTheme.primary,
              ),
            ),
          );
        }
        
        if (viewModel.error != null) {
          HWLog.event('training_log_state', data: {'state': 'error', 'error': viewModel.error.toString()});
          return _buildError(viewModel.error!);
        }
        
        HWLog.event('training_log_state', data: {'state': 'ready', 'sessionCount': viewModel.sessions.length});
        return HeavyweightScaffold(
          title: 'LOGBOOK',
          
          body: Column(
            children: [
                  
                  // Stats Summary
                  _buildStatsContainer(viewModel.stats),
                  
                  const SizedBox(height: HeavyweightTheme.spacingLg),
                  
                  // Session History
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SESSION_HISTORY:',
                          style: HeavyweightTheme.labelMedium.copyWith(
                            color: HeavyweightTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: HeavyweightTheme.spacingMd),
                        
                        Expanded(
                          child: viewModel.hasSessions 
                              ? ListView.builder(
                                  itemCount: viewModel.sessions.length,
                                  itemBuilder: (context, index) {
                                    final session = viewModel.sessions[index];
                                    return _buildSessionCard(session, viewModel);
                                  },
                                )
                              : _buildEmptyState(),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsContainer(PerformanceStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT_PERFORMANCE:',
            style: HeavyweightTheme.labelMedium.copyWith(
              color: HeavyweightTheme.primary,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('TOTAL_SESSIONS: ${stats.workoutDays}', style: HeavyweightTheme.bodySmall)),
              Expanded(child: Text('TOTAL_SETS: ${stats.totalSets}', style: HeavyweightTheme.bodySmall, textAlign: TextAlign.end)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('MANDATE_ADHERENCE: ${stats.mandateAdherence.toStringAsFixed(0)}%', style: HeavyweightTheme.bodySmall)),
              Expanded(child: Text('TOTAL_VOLUME: ${stats.totalVolume.toStringAsFixed(0)} KG', style: HeavyweightTheme.bodySmall, textAlign: TextAlign.end)),
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
      onTap: () {
        context.go('/session-detail', extra: session);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
        padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
        decoration: BoxDecoration(
          border: Border.all(color: HeavyweightTheme.textSecondary, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatDate(session.date)} - $dayName',
                  style: HeavyweightTheme.h4.copyWith(fontSize: 14),
                ),
                Text(
                  duration,
                  style: HeavyweightTheme.bodySmall.copyWith(
                    color: HeavyweightTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: HeavyweightTheme.spacingSm),
            
            // Volume
            Text(
              'VOLUME: ${volume.toStringAsFixed(0)} KG',
              style: HeavyweightTheme.bodySmall.copyWith(
                color: HeavyweightTheme.primary,
              ),
            ),
            
            const SizedBox(height: HeavyweightTheme.spacingSm),
            
            // Exercises
            ...exercises.map<Widget>((exerciseText) {
              return Padding(
                padding: const EdgeInsets.only(bottom: HeavyweightTheme.spacingXs),
                child: Text(
                  '├─ $exerciseText',
                  style: HeavyweightTheme.bodySmall.copyWith(
                    color: HeavyweightTheme.textSecondary,
                  ),
                ),
              );
            }),
            
            const SizedBox(height: HeavyweightTheme.spacingSm),
            
            // Tap indicator
            Text(
              'TAP FOR DETAILS →',
              style: HeavyweightTheme.bodySmall.copyWith(
                color: HeavyweightTheme.textSecondary,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
