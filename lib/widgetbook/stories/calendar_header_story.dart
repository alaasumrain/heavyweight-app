import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/calendar_header.dart';

WidgetbookComponent buildCalendarHeaderComponent() {
  return WidgetbookComponent(
    name: 'Calendar Header',
    useCases: [
      WidgetbookUseCase(
        name: 'Default',
        builder: (_) => CalendarHeader(
          username: 'Alex',
          days: const [
            CalendarDay(label: 'Mo', day: 4, isCompleted: true),
            CalendarDay(label: 'Tu', day: 5, isCompleted: true),
            CalendarDay(label: 'We', day: 6, isToday: true),
            CalendarDay(label: 'Th', day: 7),
            CalendarDay(label: 'Fr', day: 8),
            CalendarDay(label: 'Sa', day: 9),
            CalendarDay(label: 'Su', day: 10),
          ],
          completedWorkouts: 3,
          weekTarget: 4,
        ),
      ),
      WidgetbookUseCase(
        name: 'Empty Week',
        builder: (_) => CalendarHeader(
          username: 'Alex',
          days: const [
            CalendarDay(label: 'Mo', day: 4),
            CalendarDay(label: 'Tu', day: 5),
            CalendarDay(label: 'We', day: 6, isToday: true),
            CalendarDay(label: 'Th', day: 7),
            CalendarDay(label: 'Fr', day: 8),
            CalendarDay(label: 'Sa', day: 9),
            CalendarDay(label: 'Su', day: 10),
          ],
          completedWorkouts: 0,
          weekTarget: 4,
        ),
      ),
    ],
  );
}
