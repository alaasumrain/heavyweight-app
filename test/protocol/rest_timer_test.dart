import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heavyweight_app/fortress/protocol/widgets/rest_timer.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('allows skipping rest early after a strong set', (tester) async {
    var completed = false;

    await tester.pumpWidget(_wrap(RestTimer(
      restSeconds: 120,
      onComplete: () => completed = true,
      lastSetPerformance: 'within_mandate',
    )));

    expect(find.text('SKIP - GOOD PERFORMANCE'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(completed, isTrue);
  });

  testWidgets('recommends extending rest when the last set struggled',
      (tester) async {
    await tester.pumpWidget(_wrap(const RestTimer(
      restSeconds: 90,
      onComplete: _noop,
      lastSetPerformance: 'below_mandate',
    )));

    expect(find.text('EXTEND +30s (RECOMMENDED)'), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();

    expect(find.text('REST EXTENDED'), findsOneWidget);
  });
}

void _noop() {}
