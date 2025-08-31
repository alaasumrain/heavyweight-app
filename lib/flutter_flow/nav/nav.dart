// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '/index.dart';
import '/flutter_flow/flutter_flow_util.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) => const SplashPageWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => const SplashPageWidget(),
        ),
        FFRoute(
          name: 'splashPage',
          path: '/splashPage',
          builder: (context, params) => const SplashPageWidget(),
        ),
        FFRoute(
          name: 'introPage',
          path: '/introPage',
          builder: (context, params) => const IntroPageWidget(),
        ),
        FFRoute(
          name: 'loginPage',
          path: '/loginPage',
          builder: (context, params) => const LoginPageWidget(),
        ),
        FFRoute(
          name: 'homePage',
          path: '/homePage',
          builder: (context, params) => const HomePageWidget(),
        ),
        FFRoute(
          name: 'signUpPage',
          path: '/signUpPage',
          builder: (context, params) => const SignUpPageWidget(),
        ),
        FFRoute(
          name: 'forgotPasswordPage',
          path: '/forgotPasswordPage',
          builder: (context, params) => const ForgotPasswordPageWidget(),
        ),
        FFRoute(
          name: 'verificationPage',
          path: '/verificationPage',
          builder: (context, params) => const VerificationPageWidget(),
        ),
        FFRoute(
          name: 'resetPasswordPage',
          path: '/resetPasswordPage',
          builder: (context, params) => const ResetPasswordPageWidget(),
        ),
        FFRoute(
          name: 'basicDetailsPage',
          path: '/basicDetailsPage',
          builder: (context, params) => const BasicDetailsPageWidget(),
        ),
        FFRoute(
          name: 'genderPage',
          path: '/genderPage',
          builder: (context, params) => const GenderPageWidget(),
        ),
        FFRoute(
          name: 'agePage',
          path: '/agePage',
          builder: (context, params) => const AgePageWidget(),
        ),
        FFRoute(
          name: 'weightPage',
          path: '/weightPage',
          builder: (context, params) => const WeightPageWidget(),
        ),
        FFRoute(
          name: 'heightPage',
          path: '/heightPage',
          builder: (context, params) => const HeightPageWidget(),
        ),
        FFRoute(
          name: 'goalPage',
          path: '/goalPage',
          builder: (context, params) => const GoalPageWidget(),
        ),
        FFRoute(
          name: 'todayWorkoutPlanPage',
          path: '/todayWorkoutPlanPage',
          builder: (context, params) => const TodayWorkoutPlanPageWidget(),
        ),
        FFRoute(
          name: 'popularWorkoutPage',
          path: '/popularWorkoutPage',
          builder: (context, params) => const PopularWorkoutPageWidget(),
        ),
        FFRoute(
          name: 'workoutDetailsPage',
          path: '/workoutDetailsPage',
          builder: (context, params) => const WorkoutDetailsPageWidget(),
        ),
        FFRoute(
          name: 'playSessionPage',
          path: '/playSessionPage',
          builder: (context, params) => const PlaySessionPageWidget(),
        ),
        FFRoute(
          name: 'notificationPage',
          path: '/notificationPage',
          builder: (context, params) => const NotificationPageWidget(),
        ),
        FFRoute(
          name: 'recentWorkoutPage',
          path: '/recentWorkoutPage',
          builder: (context, params) => const RecentWorkoutPageWidget(),
        ),
        FFRoute(
          name: 'myProfilePage',
          path: '/myProfilePage',
          builder: (context, params) => const MyProfilePageWidget(),
        ),
        FFRoute(
          name: 'editProfilePage',
          path: '/editProfilePage',
          builder: (context, params) => const EditProfilePageWidget(),
        ),
        FFRoute(
          name: 'aboutUs',
          path: '/aboutUs',
          builder: (context, params) => const AboutUsWidget(),
        ),
        FFRoute(
          name: 'privacyPolicyPage',
          path: '/privacyPolicyPage',
          builder: (context, params) => const PrivacyPolicyPageWidget(),
        ),
        FFRoute(
          name: 'settingPage',
          path: '/settingPage',
          builder: (context, params) => const SettingPageWidget(),
        ),
        FFRoute(
          name: 'securityPage',
          path: '/securityPage',
          builder: (context, params) => const SecurityPageWidget(),
        ),
        FFRoute(
          name: 'changePasswordPage',
          path: '/changePasswordPage',
          builder: (context, params) => const ChangePasswordPageWidget(),
        ),
        FFRoute(
          name: 'termsAndConditionPage',
          path: '/termsAndConditionPage',
          builder: (context, params) => const TermsAndConditionPageWidget(),
        ),
        FFRoute(
          name: 'helpLineCenterPage',
          path: '/helpLineCenterPage',
          builder: (context, params) => const HelpLineCenterPageWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    // ..addAll(queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.extraMap.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, [
    bool isList = false,
  ]) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouter.of(context);
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}
