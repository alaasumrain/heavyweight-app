import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../fortress/engine/models/exercise.dart';

class SessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;
  
  const SessionDetailScreen({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final exerciseGroups = _groupSetsByExercise(session.sets);
    final totalVolume = session.sets.fold(0.0, (sum, set) => sum + (set.weight * set.actualReps));
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/training-log');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SESSION_RECORD',
                          style: HeavyweightTheme.h3.copyWith(
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          _formatDateTime(session.date),
                          style: HeavyweightTheme.bodySmall.copyWith(
                            color: HeavyweightTheme.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
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
              
              const SizedBox(height: 24),
              
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
              
              const SizedBox(height: 20),
              
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
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingSm),
          
          // Sets breakdown
          ...sets.map((set) => _buildSetDetail(set)),
          
          const SizedBox(height: HeavyweightTheme.spacingSm),
          
          // Exercise totals
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: HeavyweightTheme.textSecondary.withOpacity(0.1),
              border: Border.all(color: HeavyweightTheme.textSecondary.withOpacity(0.3)),
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
      statusColor = Colors.red;
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
      padding: const EdgeInsets.only(bottom: 8),
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
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
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