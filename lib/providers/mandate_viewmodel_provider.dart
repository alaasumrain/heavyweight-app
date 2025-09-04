import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/fortress/viewmodels/mandate_viewmodel.dart';
import '/providers/repository_provider.dart';
import '/providers/mandate_engine_provider.dart';

/// Factory provider for creating MandateViewModel with proper dependencies
class MandateViewModelProvider extends StatelessWidget {
  final Widget child;
  
  const MandateViewModelProvider({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<RepositoryProvider, MandateEngineProvider>(
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
        
        return ChangeNotifierProvider(
          create: (context) => MandateViewModel(
            repository: repositoryProvider.repository!,
            engine: engineProvider.engine,
          ),
          child: child,
        );
      },
    );
  }
}