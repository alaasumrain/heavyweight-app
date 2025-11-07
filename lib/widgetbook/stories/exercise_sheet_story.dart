import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/exercise_sheet.dart';

WidgetbookComponent buildExerciseSheetComponent() {
  return WidgetbookComponent(
    name: 'Exercise Sheet',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => const ExerciseSheet(
          title: 'Pull-up',
          variant: 'Weighted',
          sets: [
            ExerciseSetRowData(
                weight: '40', unit: 'Kg', reps: '6', isCompleted: true),
            ExerciseSetRowData(
                weight: '40', unit: 'Kg', reps: '6', isCompleted: true),
            ExerciseSetRowData(weight: '40', unit: 'Kg', reps: '6'),
            ExerciseSetRowData(weight: '45', unit: 'Kg', reps: '4'),
          ],
          note: 'Test',
        ),
      ),
      WidgetbookUseCase(
        name: 'Dropset / Warm-up',
        builder: (_) => const ExerciseSheet(
          title: 'Bench Press',
          variant: 'Barbell',
          sets: [
            ExerciseSetRowData(
              weight: '60',
              unit: 'Kg',
              reps: '10',
              isWarmup: true,
              isCompleted: true,
            ),
            ExerciseSetRowData(
              weight: '80',
              unit: 'Kg',
              reps: '6',
              isCompleted: true,
            ),
            ExerciseSetRowData(
              weight: '80',
              unit: 'Kg',
              reps: '4',
              isDropset: true,
            ),
            ExerciseSetRowData(
              weight: '60',
              unit: 'Kg',
              reps: 'AMRAP',
              isDropset: true,
            ),
          ],
        ),
      ),
    ],
  );
}
