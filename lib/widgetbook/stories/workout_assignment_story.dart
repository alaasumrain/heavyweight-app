import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/workout_assignment_card.dart';

WidgetbookComponent buildWorkoutAssignmentComponent() {
  return WidgetbookComponent(
    name: 'Workout Assignment List',
    useCases: [
      WidgetbookUseCase(
        name: 'Mandate',
        builder: (_) => WorkoutAssignmentList(
          entries: const [
            AssignmentEntry(
              id: 'swing',
              orderLabel: '01',
              title: 'American Kettlebell Swing',
              subtitle: 'Kettlebell · Posterior Chain',
              note: 'Prime hip hinge, maintain neutral spine.',
              completedSets: 1,
              totalSets: 3,
              lastPerformance: 'LAST: 24 KG × 6',
              sets: [
                AssignmentSet(
                    weight: '24',
                    unit: 'KG',
                    reps: '6 reps',
                    isCompleted: true),
                AssignmentSet(weight: '24', unit: 'KG', reps: '6 reps'),
                AssignmentSet(weight: '24', unit: 'KG', reps: '6 reps'),
              ],
            ),
            AssignmentEntry(
              id: 'wheel_rollout',
              orderLabel: '02',
              title: 'Assisted Wheel Rollout',
              subtitle: 'Cable · Core Stabilization',
              completedSets: 0,
              totalSets: 2,
              lastPerformance: 'LAST: 18 KG × 5',
              sets: [
                AssignmentSet(weight: '18', unit: 'KG', reps: '5 reps'),
                AssignmentSet(weight: '18', unit: 'KG', reps: '5 reps'),
              ],
            ),
          ],
        ),
      ),
      WidgetbookUseCase(
        name: 'Alternative Selected',
        builder: (_) => WorkoutAssignmentList(
          entries: const [
            AssignmentEntry(
              id: 'bench_press_alt',
              orderLabel: '03',
              title: 'Dumbbell Bench Press',
              subtitle: 'Free Weight · Chest',
              primaryLabel: 'BENCH PRESS',
              alternativeSelected: true,
              completedSets: 2,
              totalSets: 3,
              lastPerformance: 'LAST: 32 KG × 6',
              note: 'Keep elbows tucked to protect shoulders.',
              sets: [
                AssignmentSet(
                    weight: '32',
                    unit: 'KG',
                    reps: '6 reps',
                    isCompleted: true),
                AssignmentSet(
                    weight: '32',
                    unit: 'KG',
                    reps: '6 reps',
                    isCompleted: true),
                AssignmentSet(weight: '34', unit: 'KG', reps: '4 reps'),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
