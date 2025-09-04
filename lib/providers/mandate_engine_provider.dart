import 'package:flutter/material.dart';
import '/fortress/engine/mandate_engine.dart';

/// Provider for the MandateEngine singleton
/// Ensures single instance across the app
class MandateEngineProvider extends ChangeNotifier {
  late final MandateEngine _engine;
  
  MandateEngineProvider() {
    _engine = MandateEngine();
  }
  
  /// Get the mandate engine instance
  MandateEngine get engine => _engine;
}