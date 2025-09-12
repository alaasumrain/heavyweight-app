import 'package:flutter/foundation.dart';

/// A notifier that forwards notifications from multiple Listenables.
class CombinedRefreshNotifier extends ChangeNotifier {
  final List<Listenable> _sources;
  final List<VoidCallback> _callbacks = [];

  CombinedRefreshNotifier(this._sources) {
    for (final src in _sources) {
      void cb() {
        debugPrint('🔄 CombinedRefreshNotifier: source fired -> notifyListeners');
        notifyListeners();
      }
      src.addListener(cb);
      _callbacks.add(cb);
    }
  }

  @override
  void notifyListeners() {
    debugPrint('🔄 CombinedRefreshNotifier: notifyListeners()');
    super.notifyListeners();
  }

  @override
  void dispose() {
    for (var i = 0; i < _sources.length; i++) {
      _sources[i].removeListener(_callbacks[i]);
    }
    _callbacks.clear();
    super.dispose();
  }
}
