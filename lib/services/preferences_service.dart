import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] so widgets can depend on a simple
/// service abstraction instead of hitting the singleton directly. Keeps the UI
/// declarative and helps avoid redundant instance lookups during rebuilds.
class PreferencesService {
  SharedPreferences? _prefs;

  bool get isReady => _prefs != null;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    await initialize();
    return _prefs!;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    final prefs = await _ensurePrefs();
    return prefs.setBool(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await _ensurePrefs();
    return prefs.setString(key, value);
  }
}
