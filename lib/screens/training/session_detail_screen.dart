import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../fortress/engine/models/exercise.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/logging.dart';

class SessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;
  
  const SessionDetailScreen({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Training/SessionDetail');
    final exerciseGroups = _groupSetsByExercise(session.sets);
    final totalVolume = session.sets.fold(0.0, (sum, set) => sum + (set.weight * set.actualReps));
    
    return HeavyweightScaffold(
      title: 'SESSION_RECORD',
      subtitle: _formatDateTime(session.date),
      showBackButton: true,
      fallbackRoute: '/training-log',
      body: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Session summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                decoration: BoxDecoration(
                  border: Border.all(color: HeavyweightTheme.primary, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SESSION_SUMMARY:',
                      style: HeavyweightTheme.labelMedium.copyWith(
                        color: HeavyweightTheme.primary,
                      ),
                    ),
                    const SizedBox(height: HeavyweightTheme.spacingSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL_SETS: ${session.sets.length}', style: HeavyweightTheme.bodySmall),
                        Text('EXERCISES: ${exerciseGroups.length}', style: HeavyweightTheme.bodySmall),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL_VOLUME: ${totalVolume.toStringAsFixed(0)} KG', style: HeavyweightTheme.bodySmall),
                        Text('MANDATE_SETS: ${session.sets.where((s) => s.metMandate).length}', style: HeavyweightTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: HeavyweightTheme.spacingLg),
              
              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXERCISE_BREAKDOWN:',
                      style: HeavyweightTheme.labelMedium.copyWith(
                        color: HeavyweightTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: HeavyweightTheme.spacingMd),
                    
                    Expanded(
                      child: ListView.builder(
                        itemCount: exerciseGroups.length,
                        itemBuilder: (context, index) {
                          final entry = exerciseGroups.entries.elementAt(index);
                          return _buildExerciseDetail(entry.key, entry.value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: HeavyweightTheme.spacingMd),
              
              // Back button
              CommandButton(
                text: 'RETURN_TO_LOGBOOK',
                variant: ButtonVariant.secondary,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/training-log');
                  }
                },
              ),
            ],
          ),
        ),
      );
  }
  
  Map<String, List<SetData>> _groupSetsByExercise(List<SetData> sets) {
    final groups = <String, List<SetData>>{};
    for (final set in sets) {
      groups[set.exerciseId] = (groups[set.exerciseId] ?? [])..add(set);
    }
    
    // Sort sets within each exercise by set number
    for (final entry in groups.entries) {
      entry.value.sort((a, b) => a.setNumber.compareTo(b.setNumber));
    }
    
    return groups;
  }
  
  Widget _buildExerciseDetail(String exerciseId, List<SetData> sets) {
    final exercise = Exercise.bigSix.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => Exercise(
        id: exerciseId,
        name: exerciseId.toUpperCase(),
        muscleGroup: 'Unknown',
        prescribedWeight: 0,
        restSeconds: 180,
      ),
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.textSecondary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Text(
            exercise.name.toUpperCase(),
            style: HeavyweightTheme.h4.copyWith(
              color: HeavyweightTheme.primary,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingSm),
          
          // Sets breakdown
          ...sets.map((set) => _buildSetDetail(set)),
          
          const SizedBox(height: HeavyweightTheme.spacingSm),
          
          // Exercise totals
          Container(
            padding: const EdgeInsets.symmetric(vertical: HeavyweightTheme.spacingSm, horizontal: HeavyweightTheme.spacingSm),
            decoration: BoxDecoration(
              color: HeavyweightTheme.textSecondary.withValues(alpha: 0.1),
              border: Border.all(color: HeavyweightTheme.textSecondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL_VOLUME:',
                  style: HeavyweightTheme.bodySmall.copyWith(
                    color: HeavyweightTheme.textSecondary,
                  ),
                ),
                Text(
                  '${sets.fold(0.0, (sum, s) => sum + (s.weight * s.actualReps)).toStringAsFixed(0)} KG',
                  style: HeavyweightTheme.bodySmall.copyWith(
                    color: HeavyweightTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSetDetail(SetData set) {
    Color statusColor = HeavyweightTheme.textSecondary;
    String statusText = 'UNKNOWN';
    
    if (set.actualReps == 0) {
      statusColor = HeavyweightTheme.error;
      statusText = 'FAILURE';
    } else if (set.actualReps < 4) {
      statusColor = HeavyweightTheme.warning;
      statusText = 'BELOW_MANDATE';
    } else if (set.actualReps <= 6) {
      statusColor = HeavyweightTheme.primary;
      statusText = 'MANDATE_MET';
    } else {
      statusColor = HeavyweightTheme.accent;
      statusText = 'EXCEEDED_MANDATE';
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: HeavyweightTheme.spacingSm),
      child: Row(
        children: [
          Text(
            '├─ SET_${set.setNumber}: ',
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
            ),
          ),
          Text(
            '${set.actualReps} reps @ ${set.weight}kg',
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingXs, vertical: HeavyweightTheme.spacingXs),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime date) {
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final weekday = weekdays[date.weekday - 1];
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    return '$weekday $dateStr $timeStr';
  }
}
