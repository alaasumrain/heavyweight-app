import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/exercise_viewmodel.dart';

class ExerciseAlternativesWidget extends StatelessWidget {
  final String exerciseId;
  final String currentExerciseName;
  final VoidCallback? onSelectionChanged;

  const ExerciseAlternativesWidget({
    super.key,
    required this.exerciseId,
    required this.currentExerciseName,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseViewModel>(
      builder: (context, exerciseViewModel, child) {
        if (!exerciseViewModel.isLoaded) {
          return const SizedBox();
        }

        final alternatives = exerciseViewModel.getAlternativesFor(exerciseId);

        if (alternatives.length <= 1) {
          // No alternatives available
          return const SizedBox();
        }

        final selectedAlternative =
            exerciseViewModel.getSelectedAlternative(exerciseId);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.swap_horiz,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'EXERCISE OPTIONS',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...alternatives.map((alternative) => _buildAlternativeOption(
                      context,
                      alternative,
                      selectedAlternative?.id == alternative.id,
                      exerciseViewModel,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlternativeOption(
    BuildContext context,
    ExerciseAlternative alternative,
    bool isSelected,
    ExerciseViewModel exerciseViewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          exerciseViewModel.selectAlternative(exerciseId, alternative.id);
          onSelectionChanged?.call();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.white : Colors.grey[700]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          alternative.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(alternative.difficulty)
                                .withValues(alpha: 0.2),
                            border: Border.all(
                              color:
                                  _getDifficultyColor(alternative.difficulty),
                            ),
                          ),
                          child: Text(
                            alternative.difficulty.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  _getDifficultyColor(alternative.difficulty),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alternative.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Starting: ${alternative.prescribedWeight}kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ExerciseAlternativesBottomSheet extends StatelessWidget {
  final String exerciseId;
  final String currentExerciseName;

  const ExerciseAlternativesBottomSheet({
    super.key,
    required this.exerciseId,
    required this.currentExerciseName,
  });

  static void show(
    BuildContext context, {
    required String exerciseId,
    required String currentExerciseName,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) => ExerciseAlternativesBottomSheet(
        exerciseId: exerciseId,
        currentExerciseName: currentExerciseName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseViewModel>(
      builder: (context, exerciseViewModel, child) {
        if (!exerciseViewModel.isLoaded) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final alternatives = exerciseViewModel.getAlternativesFor(exerciseId);

        if (alternatives.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'NO ALTERNATIVES AVAILABLE',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                      letterSpacing: 1,
                    ),
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CHOOSE EXERCISE',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Current: ${currentExerciseName.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                ...alternatives.map((alternative) => _buildAlternativeCard(
                      context,
                      alternative,
                      exerciseViewModel,
                    )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlternativeCard(
    BuildContext context,
    ExerciseAlternative alternative,
    ExerciseViewModel exerciseViewModel,
  ) {
    final isSelected =
        exerciseViewModel.getSelectedAlternative(exerciseId)?.id ==
            alternative.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          exerciseViewModel.selectAlternative(exerciseId, alternative.id);
          Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.white : Colors.grey[700]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  if (isSelected) const SizedBox(width: 8),
                  Text(
                    alternative.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(alternative.difficulty)
                          .withValues(alpha: 0.2),
                      border: Border.all(
                        color: _getDifficultyColor(alternative.difficulty),
                      ),
                    ),
                    child: Text(
                      alternative.difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getDifficultyColor(alternative.difficulty),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alternative.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Starting Weight: ${alternative.prescribedWeight}kg',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
