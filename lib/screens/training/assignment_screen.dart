import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../components/ui/exercise_alternatives_widget.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/viewmodels/workout_viewmodel.dart';
import '../../providers/workout_viewmodel_provider.dart';
import '../../providers/repository_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../fortress/engine/workout_engine.dart';
import '../../fortress/engine/exercise_intel.dart';
import '../../fortress/engine/models/exercise.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../core/logging.dart';
import '../../providers/profile_provider.dart';
import '../../core/units.dart';
import '../../components/ui/workout_assignment_card.dart';
import '../../core/workout_session_manager.dart';
import '../../viewmodels/exercise_viewmodel.dart';
import '../../services/preferences_service.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  static Widget withProvider() {
    return const WorkoutViewModelProvider(
      child: AssignmentScreen(),
    );
  }

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool _showTutorial = false;
  String _lastSessionText = 'LOADING';
  String _streakText = 'LOADING';
  bool _primedLasts = false;
  Map<String, SetData> _lastByExercise = const {};
  bool _resumeAvailable = false;
  bool _assignmentBuildLogged = false;
  final Map<String, List<bool>> _setCompletion = {};
  final Map<String, int> _extraSets = {};
  final Map<String, String> _exerciseNotes = {};

  @override
  void initState() {
    super.initState();
    HWLog.screen('Training/Assignment');
    // HUD tutorial disabled per UX feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HWLog.event('assignment_init_post_frame');
      // Get preferred starting day from app state
      final appState = context.read<AppStateProvider>().appState;
      final preferredStartingDay = appState.preferredStartingDay;
      context
          .read<WorkoutViewModel>()
          .initialize(preferredStartingDay: preferredStartingDay);
      _loadSessionStats();
      _checkFirstVisit();
      _checkResume();
    });
  }

  /// Refresh workout data (for pull-to-refresh)
  Future<void> _refreshWorkout() async {
    final workoutViewModel = context.read<WorkoutViewModel>();
    await workoutViewModel.refresh();
    await _loadSessionStats();
    await _checkResume();
  }

  Future<void> _loadSessionStats() async {
    try {
      HWLog.event('assignment_load_stats_start');
      final viewModel = context.read<WorkoutViewModel>();
      final repository = context.read<RepositoryProvider>().repository;
      final stats = await viewModel.getStats();

      if (repository != null) {
        final lastSession = await repository.getLastSession();

        // Calculate days since last session
        String lastSessionDisplay = 'NO_PREVIOUS_SESSION';
        if (lastSession != null) {
          final daysSince = DateTime.now().difference(lastSession.date).inDays;
          if (daysSince == 0) {
            lastSessionDisplay = 'TODAY';
          } else if (daysSince == 1) {
            lastSessionDisplay = '1_DAY_AGO';
          } else {
            lastSessionDisplay = '${daysSince}_DAYS_AGO';
          }
        }

        // Set streak based on workout days
        final streakDisplay = '${stats.workoutDays}_SESSIONS';

        if (mounted) {
          setState(() {
            _lastSessionText = lastSessionDisplay;
            _streakText = streakDisplay;
          });
        }
        HWLog.event('assignment_load_stats_done', data: {
          'lastSession': _lastSessionText,
          'streak': _streakText,
        });
      }
    } catch (e) {
      HWLog.event('assignment_load_stats_error', data: {'error': e.toString()});
      if (mounted) {
        setState(() {
          _lastSessionText = 'SYNC_FAILED';
          _streakText = 'SYNC_FAILED';
        });
      }
    }
  }

  Future<void> _checkResume() async {
    final hasSession = await WorkoutSessionManager.hasActiveSession();
    if (!mounted) return;
    setState(() {
      _resumeAvailable = hasSession;
    });
  }

  Future<void> _primeLasts(List<PlannedExercise> planned) async {
    if (_primedLasts) return;
    final repo = context.read<RepositoryProvider>().repository;
    if (repo == null) return;
    final ids = planned.map((p) => p.exercise.id).toSet();
    try {
      final map = await repo.getLastForExercises(ids);
      if (!mounted) return;
      setState(() {
        _lastByExercise = map;
        _primedLasts = true;
      });
    } catch (e) {
      HWLog.event('assignment_prime_lasts_error',
          data: {'error': e.toString()});
    }
  }

  String _getBodyPartFocus(DailyWorkout? workout) {
    if (workout == null) return 'INITIALIZING...';

    // Just show the day name without date
    return workout.dayName;
  }

  Widget _buildMandateHeader(String focus, int exerciseCount) {
    final trimmedFocus = focus.trim();
    final focusLabel = trimmedFocus.isEmpty
        ? 'NO_PROTOCOL_ASSIGNED'
        : trimmedFocus.toUpperCase().replaceAll(' ', '_');
    final countLabel = exerciseCount <= 0
        ? '0 EXERCISES'
        : exerciseCount == 1
            ? '1 EXERCISE'
            : '$exerciseCount EXERCISES';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MANDATE',
          style: HeavyweightTheme.labelMedium.copyWith(
            color: HeavyweightTheme.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingXs),
        Text(
          focusLabel,
          style: HeavyweightTheme.h2.copyWith(
            color: HeavyweightTheme.primary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingSm),
        Text(
          countLabel,
          style: HeavyweightTheme.bodySmall.copyWith(
            color: HeavyweightTheme.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  String _getSubtitle() {
    final now = DateTime.now();
    final dayNames = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY'
    ];
    final dayName = dayNames[now.weekday - 1];
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return '$dayName | $dateStr';
  }

  void _ensureAssignmentState(String exerciseId, int totalSets) {
    if (totalSets <= 0) {
      _setCompletion[exerciseId] = <bool>[];
      return;
    }

    final existing = _setCompletion[exerciseId];
    if (existing == null) {
      _setCompletion[exerciseId] = List<bool>.filled(totalSets, false);
      return;
    }

    if (existing.length == totalSets) {
      return;
    }

    final adjusted = List<bool>.filled(totalSets, false);
    for (var i = 0; i < totalSets && i < existing.length; i++) {
      adjusted[i] = existing[i];
    }
    _setCompletion[exerciseId] = adjusted;
  }

  void _handleToggleSet(String exerciseId, int setIndex, bool value) {
    final sets = _setCompletion[exerciseId];
    if (sets == null || setIndex >= sets.length) {
      return;
    }

    setState(() {
      final updated = List<bool>.from(sets);
      updated[setIndex] = value;
      _setCompletion[exerciseId] = updated;
    });
  }

  void _handleAddSet(String exerciseId, int baseSets) {
    final effectiveBase = baseSets > 0 ? baseSets : 1;
    final currentExtra = _extraSets[exerciseId] ?? 0;
    final currentTotal = effectiveBase + currentExtra;
    _ensureAssignmentState(exerciseId, currentTotal);

    final existing =
        _setCompletion[exerciseId] ?? List<bool>.filled(currentTotal, false);
    final updated = List<bool>.from(existing)..add(false);

    setState(() {
      _setCompletion[exerciseId] = updated;
      final extra = updated.length - effectiveBase;
      if (extra > 0) {
        _extraSets[exerciseId] = extra;
      }
    });
  }

  Future<void> _handleEditNote(String exerciseId, String displayName) async {
    final initialNote = _exerciseNotes[exerciseId] ?? '';
    final controller = TextEditingController(text: initialNote);

    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: HeavyweightTheme.background,
          title: Text(
            'NOTE FOR $displayName',
            style: HeavyweightTheme.bodyLarge,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 200,
            maxLines: 4,
            style: HeavyweightTheme.bodyMedium
                .copyWith(color: HeavyweightTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Log cues, weight adjustments, or cautions…',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      final trimmed = result.trim();
      if (trimmed.isEmpty) {
        _exerciseNotes.remove(exerciseId);
      } else {
        _exerciseNotes[exerciseId] = trimmed;
      }
    });
  }

  List<AssignmentEntry> _buildAssignmentEntries(
    DailyWorkout workout,
    HWUnit unit,
    ExerciseViewModel exerciseViewModel,
  ) {
    final entries = <AssignmentEntry>[];
    for (var i = 0; i < workout.exercises.length; i++) {
      final planned = workout.exercises[i];
      final exercise = planned.exercise;
      final exerciseId = exercise.id;
      final baseSets = planned.targetSets > 0
          ? planned.targetSets
          : (exercise.setsTarget ?? 3);
      final extraSets = _extraSets[exerciseId] ?? 0;
      final totalSets = (baseSets + extraSets).clamp(1, 12);
      _ensureAssignmentState(exerciseId, totalSets);

      final completionState =
          _setCompletion[exerciseId] ?? List<bool>.filled(totalSets, false);
      final completedSets =
          completionState.where((completed) => completed).length;
      final weightText = formatWeightForUnit(planned.prescribedWeight, unit);
      final unitLabel = unit == HWUnit.kg ? 'KG' : 'LB';
      final repsLabel = '4-6 reps';

      final sets = List<AssignmentSet>.generate(totalSets, (index) {
        final isCompleted =
            index < completionState.length && completionState[index];
        return AssignmentSet(
          weight: weightText,
          unit: unitLabel,
          reps: repsLabel,
          isCompleted: isCompleted,
          onToggle: (value) => _handleToggleSet(exerciseId, index, value),
        );
      });

      final last = _lastByExercise[exerciseId];
      final lastLabel = last == null
          ? 'LAST: —'
          : 'LAST: ${formatWeightForUnit(last.weight, unit)} '
              '$unitLabel × ${last.actualReps}';

      final hasAlternatives = exerciseViewModel.isLoaded &&
          exerciseViewModel.hasAlternatives(exerciseId);
      final selectedAlt = exerciseViewModel.getSelectedAlternative(exerciseId);
      var displayName = _formatToken(exercise.name);
      String? primaryLabel;
      var alternativeSelected = false;
      if (selectedAlt != null && selectedAlt.id != exerciseId) {
        alternativeSelected = true;
        primaryLabel = displayName;
        displayName = _formatToken(selectedAlt.name);
      }

      final subtitleParts = <String>[];
      if (exercise.muscleGroup.isNotEmpty) {
        subtitleParts.add(_formatToken(exercise.muscleGroup));
      }
      subtitleParts.add('${planned.restSeconds}s rest');
      final subtitle = subtitleParts.join(' · ');

      entries.add(
        AssignmentEntry(
          id: exerciseId,
          orderLabel: (i + 1).toString().padLeft(2, '0'),
          title: displayName,
          subtitle: subtitle,
          note: _exerciseNotes[exerciseId],
          sets: sets,
          completedSets: completedSets,
          totalSets: totalSets,
          lastPerformance: lastLabel,
          primaryLabel: primaryLabel,
          alternativeSelected: alternativeSelected,
          needsCalibration: planned.needsCalibration,
          onTap: () => _showExerciseInfo(exercise),
          onSwap: hasAlternatives
              ? () => ExerciseAlternativesBottomSheet.show(
                    context,
                    exerciseId: exerciseId,
                    currentExerciseName: exercise.name,
                  )
              : null,
          onAddSet: () => _handleAddSet(exerciseId, baseSets),
          onAddNote: () => _handleEditNote(exerciseId, displayName),
        ),
      );
    }
    return entries;
  }

  Future<void> _checkFirstVisit() async {
    final prefs = context.read<PreferencesService>();
    final hasSeenTutorial =
        prefs.getBool('has_seen_hud_tutorial', defaultValue: false);

    if (!hasSeenTutorial && mounted) {
      // Show tutorial after a brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showTutorial = true;
          });
        }
      });
    }
  }

  Future<void> _dismissTutorial() async {
    final prefs = context.read<PreferencesService>();
    await prefs.setBool('has_seen_hud_tutorial', true);

    setState(() {
      _showTutorial = false;
    });
  }

  void _showExerciseInfo(Exercise exercise) {
    HWLog.event('assignment_show_exercise_info',
        data: {'exercise': exercise.id});
    final routerContext = context;
    final intel = ExerciseIntel.getIntelProfile(exercise.id);
    final profile = context.read<ProfileProvider>();
    final preferredUnit = profile.unit == Unit.kg ? HWUnit.kg : HWUnit.lb;
    final summaryLines = _buildExerciseSummary(exercise, preferredUnit);
    final formProtocol =
        intel.formProtocol.take(3).map(_formatIntelLine).toList();
    final failureSignals =
        intel.commonFailures.take(2).map(_formatIntelLine).toList();
    final abortDirective = _formatIntelLine(intel.abortConditions);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogCtx) => Dialog(
        insetPadding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
        backgroundColor: HeavyweightTheme.background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = MediaQuery.of(context).size;
            final maxWidth = screenSize.width < 420
                ? screenSize.width - HeavyweightTheme.spacingLg * 2
                : 360.0;
            final maxHeight = screenSize.height.clamp(360.0, 520.0).toDouble();
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: Container(
                padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
                decoration: BoxDecoration(
                  border: Border.all(color: HeavyweightTheme.primary),
                  color: HeavyweightTheme.background,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name.toUpperCase(),
                              style: HeavyweightTheme.h3,
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingMd),
                            _buildIntelSection(
                              'TRAINING_DIRECTIVE',
                              summaryLines,
                              HeavyweightTheme.primary,
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingLg),
                            _buildIntelSection(
                              'FORM_CHECKLIST',
                              formProtocol,
                              HeavyweightTheme.accent,
                            ),
                            if (failureSignals.isNotEmpty) ...[
                              const SizedBox(
                                  height: HeavyweightTheme.spacingLg),
                              _buildIntelSection(
                                'COMMON_FAILURES',
                                failureSignals,
                                Colors.amber.shade600,
                              ),
                            ],
                            const SizedBox(height: HeavyweightTheme.spacingLg),
                            _buildIntelNotice(
                              'ABORT_CONDITIONS',
                              abortDirective,
                              HeavyweightTheme.error,
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingLg),
                            CommandButton(
                              text: 'VIEW FULL INTEL',
                              variant: ButtonVariant.secondary,
                              onPressed: () {
                                Navigator.of(dialogCtx, rootNavigator: true)
                                    .pop();
                                final router = GoRouter.of(routerContext);
                                router.go(
                                  '/exercise-intel',
                                  extra: {
                                    'exerciseId': exercise.id,
                                    'exerciseName': exercise.name,
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: HeavyweightTheme.spacingMd),
                    CommandButton(
                      text: 'CLOSE',
                      size: ButtonSize.medium,
                      onPressed: () {
                        Navigator.of(dialogCtx, rootNavigator: true).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_assignmentBuildLogged) {
      HWLog.event('assignment_build');
      _assignmentBuildLogged = true;
    }
    return Consumer<WorkoutViewModel>(
      builder: (context, viewModel, child) {
        final workout = viewModel.todaysWorkout;

        if (viewModel.error == 'AUTHENTICATION_REQUIRED') {
          return _buildAuthRequired();
        }

        if (workout == null) {
          if (viewModel.isLoading) {
            return HeavyweightScaffold(
              title: 'ASSIGNMENT',
              subtitle: _getSubtitle(),
              showBackButton: false,
              body: const Center(
                child:
                    CircularProgressIndicator(color: HeavyweightTheme.primary),
              ),
            );
          }
          return _buildRestDay();
        }

        if (!_primedLasts) {
          Future.microtask(() => _primeLasts(workout.exercises));
        }

        final listView = RefreshIndicator(
          color: HeavyweightTheme.primary,
          backgroundColor: HeavyweightTheme.surface,
          onRefresh: _refreshWorkout,
          child: _buildAssignmentList(viewModel, workout),
        );

        return HeavyweightScaffold(
          title: 'ASSIGNMENT',
          subtitle: _getSubtitle(),
          navIndex: 0,
          showNavigation: true,
          bodyPadding: const EdgeInsets.symmetric(
            horizontal: HeavyweightTheme.spacingMd,
          ),
          body: Stack(
            children: [
              listView,
              Positioned(
                left: HeavyweightTheme.spacingLg,
                right: HeavyweightTheme.spacingLg,
                bottom: HeavyweightTheme.spacingLg +
                    MediaQuery.of(context).padding.bottom,
                child: CommandButton(
                  text: 'BEGIN TRAINING',
                  onPressed: () {
                    final router = GoRouter.of(context);
                    router.go('/daily-workout');
                  },
                ),
              ),
              IgnorePointer(
                ignoring: !_showTutorial,
                child: AnimatedOpacity(
                  opacity: _showTutorial ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.linear,
                  child: _buildHudTutorialOverlay(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignmentList(
      WorkoutViewModel viewModel, DailyWorkout workout) {
    final profile = context.watch<ProfileProvider>();
    final unit = profile.unit == Unit.kg ? HWUnit.kg : HWUnit.lb;
    final exerciseViewModel = context.watch<ExerciseViewModel>();
    final children = <Widget>[
      if (_resumeAvailable) ...[
        const SizedBox(height: HeavyweightTheme.spacingMd),
        _buildResumeBanner(workout),
      ],
      const SizedBox(height: HeavyweightTheme.spacingMd),
      _buildMandateHeader(_getBodyPartFocus(workout), workout.exercises.length),
      const SizedBox(height: HeavyweightTheme.spacingLg),
      Text(
        'TRAINING_SEQUENCE:',
        style: HeavyweightTheme.labelMedium
            .copyWith(color: HeavyweightTheme.primary),
      ),
      const SizedBox(height: HeavyweightTheme.spacingMd),
    ];

    if (exerciseViewModel.error != null) {
      children.addAll([
        _buildAlternativesErrorBanner(
          context,
          exerciseViewModel.error!,
          exerciseViewModel,
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
      ]);
    }

    final entries = _buildAssignmentEntries(workout, unit, exerciseViewModel);

    if (entries.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HeavyweightTheme.spacingLg,
          ),
          child: Text(
            'NO EXERCISES AVAILABLE',
            style: HeavyweightTheme.bodyMedium.copyWith(
              color: HeavyweightTheme.textSecondary,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      children.add(
        WorkoutAssignmentList(
          entries: entries,
          padding: EdgeInsets.zero,
        ),
      );
    }

    children.add(const SizedBox(height: HeavyweightTheme.spacingXl));
    if (viewModel.isLoading) {
      children.addAll([
        const SizedBox(height: HeavyweightTheme.spacingLg),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HeavyweightTheme.primary,
                ),
              ),
              SizedBox(width: HeavyweightTheme.spacingSm),
              Text('SYNCING…'),
            ],
          ),
        ),
      ]);
    }
    children.add(const SizedBox(
      height: HeavyweightTheme.buttonHeight + HeavyweightTheme.spacingXxl,
    ));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: HeavyweightTheme.spacingMd,
      ),
      children: children,
    );
  }

  Widget _buildAlternativesErrorBanner(
      BuildContext context, String error, ExerciseViewModel exerciseViewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.danger),
        color: HeavyweightTheme.danger.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALTERNATIVE CONFIGURATION FAILED',
            style: HeavyweightTheme.bodyMedium.copyWith(
              color: HeavyweightTheme.danger,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingXs),
          Text(
            error.toUpperCase(),
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          CommandButton(
            text: 'RETRY LOADING ALTERNATIVES',
            size: ButtonSize.small,
            variant: ButtonVariant.secondary,
            onPressed: () async {
              await exerciseViewModel.initialize();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResumeBanner(DailyWorkout workout) {
    return Container(
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border:
            Border.all(color: HeavyweightTheme.primary.withValues(alpha: 0.6)),
        color: HeavyweightTheme.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRAINING IN PROGRESS', style: HeavyweightTheme.labelMedium),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Text(
            'Training paused. Resume to keep the mandate alive.',
            style: HeavyweightTheme.bodySmall
                .copyWith(color: HeavyweightTheme.textSecondary),
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          CommandButton(
            text: 'RESUME TRAINING',
            size: ButtonSize.medium,
            onPressed: () {
              final router = GoRouter.of(context);
              router.go('/protocol', extra: workout);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthRequired() {
    return HeavyweightScaffold(
      showBackButton: false,
      navIndex: 0,
      showNavigation: true,
      title: 'ASSIGNMENT',
      subtitle: _getSubtitle(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  color: HeavyweightTheme.secondary, size: 48),
              const SizedBox(height: HeavyweightTheme.spacingLg),
              Text('AUTH REQUIRED',
                  style: HeavyweightTheme.h3, textAlign: TextAlign.center),
              const SizedBox(height: HeavyweightTheme.spacingSm),
              Text(
                'AUTHENTICATE TO RETRIEVE CURRENT MANDATE.',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodySmall
                    .copyWith(color: HeavyweightTheme.textSecondary),
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              CommandButton(
                text: 'SIGN IN',
                onPressed: () => context.go('/auth'),
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              CommandButton(
                text: 'RETRY',
                variant: ButtonVariant.secondary,
                onPressed: () => context.read<WorkoutViewModel>().initialize(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestDay() {
    return HeavyweightScaffold(
      showBackButton: false,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block,
                color: HeavyweightTheme.danger,
                size: 100,
                semanticLabel: 'Rest day enforced',
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              Text(
                'REST DAY ENFORCED',
                style: HeavyweightTheme.h2.copyWith(
                  color: HeavyweightTheme.danger,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              Text(
                'RECOVERY PROTOCOL ENFORCED.\nADAPTATION OCCURS DURING REST.',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingXxl),
              Text(
                'NEXT WORKOUT: TOMORROW',
                style: HeavyweightTheme.labelSmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHudTutorialOverlay() {
    return Container(
      color: HeavyweightTheme.background.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: HeavyweightTheme.spacingXl),
                Text(
                  'HUD_ORIENTATION',
                  style: HeavyweightTheme.h3,
                ),
                const SizedBox(height: HeavyweightTheme.spacingXxl),
                Container(
                  padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: HeavyweightTheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildHudLabel('[1] YOUR WORKOUT',
                          'TODAYS ASSIGNED TRAINING PROTOCOL'),
                      const SizedBox(height: HeavyweightTheme.spacingLg),
                      _buildHudLabel(
                          '[2] YOUR LOGBOOK', 'ACCESS VIA BOTTOM NAVIGATION'),
                      const SizedBox(height: HeavyweightTheme.spacingLg),
                      _buildHudLabel('[3] YOUR PROFILE',
                          'SYSTEM SETTINGS AND CONFIGURATION'),
                    ],
                  ),
                ),
                const SizedBox(height: HeavyweightTheme.spacingXl),
                CommandButton(
                  text: 'INTERFACE_UNDERSTOOD',
                  semanticLabel: 'Dismiss tutorial',
                  onPressed: _dismissTutorial,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHudLabel(String label, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HeavyweightTheme.bodyMedium.copyWith(
            color: HeavyweightTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: HeavyweightTheme.spacingMd),
        Expanded(
          child: Text(
            description,
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  List<String> _buildExerciseSummary(Exercise exercise, HWUnit unit) {
    final weight = formatWeightForUnit(exercise.prescribedWeight, unit);
    final unitLabel = unit == HWUnit.kg ? 'KG' : 'LB';
    return [
      'TARGET_MUSCLE: ${_formatToken(exercise.muscleGroup)}',
      'TRAINING TARGET: ${exercise.targetReps} REPS @ $weight $unitLabel',
      'REST_BETWEEN_SETS: ${_formatRest(exercise.restSeconds)}',
    ];
  }

  String _formatToken(String value) {
    return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), '_');
  }

  String _formatRest(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final minutePart = minutes > 0 ? '$minutes MIN' : '';
    final secondPart = remainingSeconds > 0
        ? '${remainingSeconds.toString().padLeft(2, '0')} SEC'
        : '';
    if (minutePart.isNotEmpty && secondPart.isNotEmpty) {
      return '$minutePart $secondPart';
    }
    return minutePart.isNotEmpty ? minutePart : secondPart;
  }

  String _formatIntelLine(String line) {
    return line.trim().toUpperCase();
  }

  Widget _buildIntelSection(String title, List<String> lines, Color accent) {
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HeavyweightTheme.bodyMedium.copyWith(
            color: accent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingSm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.4)),
            color: HeavyweightTheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(
                        bottom: HeavyweightTheme.spacingSm),
                    child: Text(
                      line,
                      style: HeavyweightTheme.bodySmall.copyWith(
                        color: HeavyweightTheme.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIntelNotice(String title, String body, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HeavyweightTheme.bodyMedium.copyWith(
            color: accent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingSm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.4)),
            color: HeavyweightTheme.surface,
          ),
          child: Text(
            body,
            style: HeavyweightTheme.bodySmall.copyWith(
              color: accent,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
