import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fortress/viewmodels/logbook_viewmodel.dart';
import 'repository_provider.dart';

/// Provider for LogbookViewModel
/// Ensures proper dependency injection and lifecycle management
class LogbookViewModelProvider extends StatelessWidget {
  final Widget child;

  const LogbookViewModelProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RepositoryProvider>(
      builder: (context, repositoryProvider, _) {
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
          create: (_) =>
              LogbookViewModel(repository: repositoryProvider.repository!),
          child: child,
        );
      },
    );
  }
}
