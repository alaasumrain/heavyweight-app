import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../fortress/engine/models/exercise.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/logging.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/units.dart';

class SessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const SessionDetailScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Training/SessionDetail');
    final exerciseGroups = _groupSetsByExercise(session.sets);
    final totalVolume = session.sets
        .fold(0.0, (sum, set) => sum + (set.weight * set.actualReps));

    return HeavyweightScaffold(
      title: 'SESSION_RECORD',
      subtitle: _formatDateTime(session.date),
      showBackButton: true,
      fallbackRoute: '/app?tab=1',
      actions: [
        IconButton(
          onPressed: () => _exportCsv(context, session),
          icon: const Icon(Icons.download, color: Colors.white),
          tooltip: 'EXPORT CSV',
        ),
      ],
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
                  Wrap(
                    spacing: HeavyweightTheme.spacingMd,
                    runSpacing: HeavyweightTheme.spacingSm,
                    children: [
                      _buildSummaryStat(
                          'TOTAL_SETS', session.sets.length.toString()),
                      _buildSummaryStat(
                          'EXERCISES', exerciseGroups.length.toString()),
                      _buildSummaryStat('TOTAL_VOLUME',
                          '${totalVolume.toStringAsFixed(0)} KG'),
                      _buildSummaryStat(
                          'IN_RANGE_SETS',
                          session.sets
                              .where((s) => s.metMandate)
                              .length
                              .toString()),
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
                        return _buildExerciseDetail(
                            context, entry.key, entry.value);
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
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  context.go('/app?tab=1');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HeavyweightTheme.spacingSm,
        vertical: HeavyweightTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.secondary),
      ),
      child: Text(
        '$label: $value',
        style: HeavyweightTheme.bodySmall.copyWith(
          color: HeavyweightTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _exportCsv(BuildContext context, WorkoutSession session) async {
    final buffer = StringBuffer();
    buffer.writeln(
        'ts,exercise_id,phase,set_idx,signed_kg,effective_kg,reps,est1rm_kg,note');
    for (final s in session.sets) {
      final ts = s.timestamp.toIso8601String();
      final ex = s.exerciseId;
      final phase = s.metMandate || s.exceededMandate || s.isFailure
          ? 'WORKING'
          : 'UNKNOWN';
      final setIdx = s.setNumber;
      final signed = s.weight.toStringAsFixed(1);
      final effective = signed; // if BW known, adjust here in future
      final reps = s.actualReps;
      final est1rm = '';
      final note = '';
      buffer.writeln(
          '$ts,$ex,$phase,$setIdx,$signed,$effective,$reps,$est1rm,$note');
    }
    final csv = buffer.toString();
    await Clipboard.setData(ClipboardData(text: csv));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('CSV copied to clipboard'),
            duration: Duration(seconds: 1)),
      );
    }
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

  Widget _buildExerciseDetail(
      BuildContext context, String exerciseId, List<SetData> sets) {
    final exercise = Exercise.getById(exerciseId) ??
        Exercise(
          id: exerciseId,
          name: exerciseId.toUpperCase(),
          muscleGroup: 'Unknown',
          prescribedWeight: 0,
          restSeconds: 180,
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
          ...sets.map((set) => _buildSetDetail(context, set)),

          const SizedBox(height: HeavyweightTheme.spacingSm),

          // Exercise totals
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: HeavyweightTheme.spacingSm,
                horizontal: HeavyweightTheme.spacingSm),
            decoration: BoxDecoration(
              color: HeavyweightTheme.textSecondary.withValues(alpha: 0.1),
              border: Border.all(
                  color: HeavyweightTheme.textSecondary.withValues(alpha: 0.3)),
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

  Widget _buildSetDetail(BuildContext context, SetData set) {
    Color statusColor = HeavyweightTheme.textSecondary;
    String statusText = 'UNKNOWN';

    if (set.actualReps == 0) {
      statusColor = HeavyweightTheme.error;
      statusText = 'FAILURE';
    } else if (set.actualReps < 4) {
      statusColor = HeavyweightTheme.warning;
      statusText = 'BELOW_RANGE';
    } else if (set.actualReps <= 6) {
      statusColor = HeavyweightTheme.primary;
      statusText = 'IN_RANGE';
    } else {
      statusColor = HeavyweightTheme.accent;
      statusText = 'ABOVE_RANGE';
    }

    // Determine user unit
    final unit =
        context.read<ProfileProvider>().unit == Unit.kg ? HWUnit.kg : HWUnit.lb;

    // Bodyweight load display
    String loadDisplay;
    if (set.exerciseId == 'pullup' ||
        set.exerciseId == 'dips' ||
        set.exerciseId == 'dip' ||
        set.exerciseId == 'weighted_dips') {
      if (set.weight > 0) {
        loadDisplay =
            'LOAD: BW + ${formatWeightForUnit(set.weight, unit)} ${unit == HWUnit.kg ? 'KG' : 'LB'}';
      } else if (set.weight < 0) {
        loadDisplay =
            'LOAD: BW - ${formatWeightForUnit(set.weight.abs(), unit)} ${unit == HWUnit.kg ? 'KG' : 'LB'} (assist)';
      } else {
        loadDisplay = 'LOAD: BW';
      }
    } else {
      loadDisplay =
          'LOAD: ${formatWeightForUnit(set.weight, unit)} ${unit == HWUnit.kg ? 'KG' : 'LB'}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: HeavyweightTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('├─ SET_${set.setNumber}: ',
              style: HeavyweightTheme.bodySmall
                  .copyWith(color: HeavyweightTheme.textSecondary)),
          const SizedBox(width: HeavyweightTheme.spacingXs),
          Expanded(
            child: Text(
              '$loadDisplay · REPS: ${set.actualReps}',
              style: HeavyweightTheme.bodySmall
                  .copyWith(color: HeavyweightTheme.primary),
              softWrap: true,
            ),
          ),
          const SizedBox(width: HeavyweightTheme.spacingXs),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: HeavyweightTheme.spacingXs,
                vertical: HeavyweightTheme.spacingXs),
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
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return '$weekday $dateStr $timeStr';
  }
}
