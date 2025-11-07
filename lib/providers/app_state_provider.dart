import 'package:flutter/foundation.dart';

import '/core/app_state.dart';
import '/core/logging.dart';

/// Provider for AppState to make it available throughout the app.
///
/// Async initialization is triggered explicitly via [initialize] so callers can
/// await readiness before wiring the provider into the widget tree. This keeps
/// provider construction side-effect free, which aligns better with Flutter's
/// lifecycle expectations.
class AppStateProvider extends ChangeNotifier {
  AppStateProvider({AppState? appState}) : _appState = appState ?? AppState() {
    _appState.addListener(_handleAppStateChange);
  }

  final AppState _appState;
  bool _isInitialized = false;
  bool _initializing = false;

  AppState get appState => _appState;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized || _initializing) {
      return;
    }
    _initializing = true;

    if (kDebugMode) {
      debugPrint('HW AppStateProvider: initializing');
    }

    try {
      await _appState.initialize();
      _isInitialized = true;
      HWLog.event('provider_initialized', data: {
        'provider': identityHashCode(this),
      });
      notifyListeners();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('HW AppStateProvider: initialization error: $error');
        debugPrint(stackTrace.toString());
      }
      // Mark initialized to prevent downstream waits from hanging forever.
      _isInitialized = true;
      notifyListeners();
      HWLog.event('provider_initialize_failed', data: {
        'provider': identityHashCode(this),
        'error': error.toString(),
      });
    } finally {
      _initializing = false;
    }
  }

  void _handleAppStateChange() {
    if (kDebugMode) {
      debugPrint('HW AppStateProvider: state changed');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _appState.removeListener(_handleAppStateChange);
    super.dispose();
  }
}
