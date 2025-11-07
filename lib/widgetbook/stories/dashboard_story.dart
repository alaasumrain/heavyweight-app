import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/workout_cards.dart';

WidgetbookComponent buildDashboardComponent() {
  return WidgetbookComponent(
    name: 'Dashboard Cards',
    useCases: [
      WidgetbookUseCase(
        name: 'Weekly Progress',
        builder: (_) => const WeeklyProgressCard(
          completedWorkouts: 3,
          totalWorkouts: 4,
        ),
      ),
      WidgetbookUseCase(
        name: 'Workout Day Card',
        builder: (_) => const WorkoutDayCard(
          title: 'Pull Day',
          subtitle: '5 exercises',
        ),
      ),
    ],
  );
}
