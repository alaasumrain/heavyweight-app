import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/core/app_state.dart';
import '/core/logging.dart';

/// Provider for AppState to make it available throughout the app
class AppStateProvider extends ChangeNotifier {
  late final AppState _appState;
  bool _isInitialized = false;
  
  AppState get appState => _appState;
  bool get isInitialized => _isInitialized;
  
  AppStateProvider() {
    if (kDebugMode) {
      debugPrint('🔧 AppStateProvider: Constructor called');
    }
    _appState = AppState();
    HWLog.event('provider_constructed', data: {
      'provider': identityHashCode(this),
    });
    _initialize();
  }
  
  Future<void> _initialize() async {
    if (kDebugMode) {
      debugPrint('⏳ AppStateProvider: Starting initialization...');
    }
    try {
      debugPrint('🔧 AppStateProvider: About to call _appState.initialize()');
      await _appState.initialize();
      debugPrint('🔧 AppStateProvider: _appState.initialize() completed');
      debugPrint('🔧 AppStateProvider: About to log state snapshot');
      // Snapshot state after initialization - temporarily commented out
      // HWLog.appStateSnapshot({
      //   'phase': 'post_initialize',
      //   'legalAccepted': _appState.legalAccepted,
      //   'manifestoCommitted': _appState.manifestoCommitted,
      //   'trainingExperience': _appState.trainingExperience,
      //   'trainingFrequency': _appState.trainingFrequency,
      //   'unitPreference': _appState.unitPreference,
      //   'physicalStats': _appState.physicalStats,
      //   'trainingObjective': _appState.trainingObjective,
      //   'isAuthenticated': _appState.isAuthenticated,
      //   'nextRoute': _appState.nextRoute,
      // });
      debugPrint('🔧 AppStateProvider: State snapshot logged (commented out)');
      if (kDebugMode) {
        debugPrint('✅ AppStateProvider: AppState initialized');
      }
      // Mark as initialized immediately to allow routing to proceed
      debugPrint('🕰️ AppStateProvider: Setting _isInitialized = true');
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('🎯 AppStateProvider: Marked as initialized, notifying listeners');
      }
      HWLog.event('provider_notify', data: {
        'provider': identityHashCode(this),
        'isInitialized': _isInitialized,
      });
      notifyListeners();
    } catch (e, stackTrace) {
      // Handle initialization errors gracefully
      if (kDebugMode) {
        debugPrint('❌ AppStateProvider: Initialization error: $e');
        debugPrint('❌ AppStateProvider: Stack trace: $stackTrace');
      }
      // Still mark as initialized to prevent infinite loading
      debugPrint('🔧 AppStateProvider: Error path - setting _isInitialized = true');
      _isInitialized = true;
      debugPrint('🔧 AppStateProvider: Error path - calling notifyListeners()');
      notifyListeners();
    }
  }
}
