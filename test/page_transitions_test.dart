import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:heavyweight_app/core/page_transitions.dart';

Future<Page<dynamic>> _buildTransitionPage(
  WidgetTester tester,
  Page<dynamic> Function(BuildContext context, GoRouterState state) builder,
) async {
  late Page<dynamic> capturedPage;

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          capturedPage = builder(context, state);
          return capturedPage;
        },
      ),
    ],
    initialLocation: '/',
  );

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pump();

  return capturedPage;
}

void main() {
  testWidgets('fadeTransition returns CustomTransitionPage with child',
      (tester) async {
    final child = const Text('Fade');
    final page = await _buildTransitionPage(
      tester,
      (context, state) =>
          HeavyweightPageTransitions.fadeTransition(context, state, child),
    );

    expect(page, isA<CustomTransitionPage>());
    expect((page as CustomTransitionPage).child, equals(child));
  });

  testWidgets('slideUpTransition returns CustomTransitionPage with dialog flag',
      (tester) async {
    final child = const Text('Slide Up');
    final page = await _buildTransitionPage(
      tester,
      (context, state) =>
          HeavyweightPageTransitions.slideUpTransition(context, state, child),
    );

    expect(page, isA<CustomTransitionPage>());
    final transitionPage = page as CustomTransitionPage;
    expect(transitionPage.child, equals(child));
    expect(transitionPage.fullscreenDialog, isTrue);
  });

  testWidgets('slideHorizontalTransition returns CustomTransitionPage',
      (tester) async {
    final child = const Text('Slide Horizontal');
    final page = await _buildTransitionPage(
      tester,
      (context, state) => HeavyweightPageTransitions.slideHorizontalTransition(
          context, state, child),
    );

    expect(page, isA<CustomTransitionPage>());
    expect((page as CustomTransitionPage).child, equals(child));
  });

  testWidgets('noTransition returns NoTransitionPage', (tester) async {
    final child = const Text('No Transition');
    final page = await _buildTransitionPage(
      tester,
      (context, state) =>
          HeavyweightPageTransitions.noTransition(context, state, child),
    );

    expect(page, isA<NoTransitionPage>());
    expect((page as NoTransitionPage).child, equals(child));
  });
}
