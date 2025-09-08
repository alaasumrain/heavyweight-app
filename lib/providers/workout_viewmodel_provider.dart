import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/fortress/viewmodels/workout_viewmodel.dart';
import '/providers/repository_provider.dart';
import '/providers/workout_engine_provider.dart';

/// Factory provider for creating WorkoutViewModel with proper dependencies
class WorkoutViewModelProvider extends StatelessWidget {
  final Widget child;
  
  const WorkoutViewModelProvider({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<RepositoryProvider, WorkoutEngineProvider>(
      builder: (context, repositoryProvider, engineProvider, _) {
        if (repositoryProvider.repository == null) {
          // Return a loading state if repository is not ready
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        
        // Initialize engine with repository if not already done
        if (!engineProvider.isInitialized) {
          engineProvider.initialize(repositoryProvider.repository!);
        }
        
        return ChangeNotifierProvider(
          create: (context) => WorkoutViewModel(
            repository: repositoryProvider.repository!,
            engine: engineProvider.engine,
          ),
          child: child,
        );
      },
    );
  }
}