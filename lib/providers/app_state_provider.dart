import 'package:flutter/material.dart';
import '/core/app_state.dart';

/// Provider for AppState to make it available throughout the app
class AppStateProvider extends ChangeNotifier {
  late final AppState _appState;
  bool _isInitialized = false;
  
  AppState get appState => _appState;
  bool get isInitialized => _isInitialized;
  
  AppStateProvider() {
    _appState = AppState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _appState.initialize();
    _isInitialized = true;
    notifyListeners();
  }
}