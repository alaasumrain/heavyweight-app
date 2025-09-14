import 'package:flutter/foundation.dart';
import 'result.dart';

/// Command pattern implementation following Flutter architecture best practices
/// Encapsulates async operations with loading states and error handling
abstract class Command<T> extends ChangeNotifier {
  bool _isExecuting = false;
  Result<T>? _lastResult;
  
  /// Whether the command is currently executing
  bool get isExecuting => _isExecuting;
  
  /// The last result from executing this command
  Result<T>? get lastResult => _lastResult;
  
  /// Whether the last execution was successful
  bool get wasSuccessful => _lastResult?.isSuccess ?? false;
  
  /// Whether the last execution failed
  bool get hasFailed => _lastResult?.isError ?? false;
  
  /// The error from the last execution, if any
  Exception? get lastError => _lastResult?.error;
  
  /// The value from the last successful execution, if any
  T? get lastValue => _lastResult?.getOrNull();
  
  /// Execute the command and return the result
  Future<Result<T>> execute();
  
  /// Clear the last result
  void clearResult() {
    _lastResult = null;
    notifyListeners();
  }
  
  /// Internal method to update execution state
  void _setExecuting(bool executing) {
    if (_isExecuting != executing) {
      _isExecuting = executing;
      notifyListeners();
    }
  }
  
  /// Internal method to set the result
  void _setResult(Result<T> result) {
    _lastResult = result;
    notifyListeners();
  }
}

/// Command with no parameters
class Command0<T> extends Command<T> {
  final Future<Result<T>> Function() _action;
  
  Command0(this._action);
  
  @override
  Future<Result<T>> execute() async {
    if (_isExecuting) {
      return _lastResult ?? const Error(HeavyweightException('Command already executing'));
    }
    
    _setExecuting(true);
    
    try {
      final result = await _action();
      _setResult(result);
      return result;
    } catch (e) {
      final error = Error<T>(e is Exception ? e : Exception(e.toString()));
      _setResult(error);
      return error;
    } finally {
      _setExecuting(false);
    }
  }
}

/// Command with one parameter
class Command1<P, T> extends Command<T> {
  final Future<Result<T>> Function(P parameter) _action;
  
  Command1(this._action);
  
  @override
  Future<Result<T>> execute() async {
    throw UnsupportedError('Use executeWith(parameter) for Command1');
  }
  
  /// Execute the command with a parameter
  Future<Result<T>> executeWith(P parameter) async {
    if (_isExecuting) {
      return _lastResult ?? const Error(HeavyweightException('Command already executing'));
    }
    
    _setExecuting(true);
    
    try {
      final result = await _action(parameter);
      _setResult(result);
      return result;
    } catch (e) {
      final error = Error<T>(e is Exception ? e : Exception(e.toString()));
      _setResult(error);
      return error;
    } finally {
      _setExecuting(false);
    }
  }
}

/// Command with two parameters  
class Command2<P1, P2, T> extends Command<T> {
  final Future<Result<T>> Function(P1 p1, P2 p2) _action;
  
  Command2(this._action);
  
  @override
  Future<Result<T>> execute() async {
    throw UnsupportedError('Use executeWith(p1, p2) for Command2');
  }
  
  /// Execute the command with parameters
  Future<Result<T>> executeWith(P1 p1, P2 p2) async {
    if (_isExecuting) {
      return _lastResult ?? const Error(HeavyweightException('Command already executing'));
    }
    
    _setExecuting(true);
    
    try {
      final result = await _action(p1, p2);
      _setResult(result);
      return result;
    } catch (e) {
      final error = Error<T>(e is Exception ? e : Exception(e.toString()));
      _setResult(error);
      return error;
    } finally {
      _setExecuting(false);
    }
  }
}

/// Command with three parameters
class Command3<P1, P2, P3, T> extends Command<T> {
  final Future<Result<T>> Function(P1 p1, P2 p2, P3 p3) _action;
  
  Command3(this._action);
  
  @override
  Future<Result<T>> execute() async {
    throw UnsupportedError('Use executeWith(p1, p2, p3) for Command3');
  }
  
  /// Execute the command with parameters
  Future<Result<T>> executeWith(P1 p1, P2 p2, P3 p3) async {
    if (_isExecuting) {
      return _lastResult ?? const Error(HeavyweightException('Command already executing'));
    }
    
    _setExecuting(true);
    
    try {
      final result = await _action(p1, p2, p3);
      _setResult(result);
      return result;
    } catch (e) {
      final error = Error<T>(e is Exception ? e : Exception(e.toString()));
      _setResult(error);
      return error;
    } finally {
      _setExecuting(false);
    }
  }
}

/// Sync command with no parameters
class SyncCommand0<T> extends Command<T> {
  final Result<T> Function() _action;
  
  SyncCommand0(this._action);
  
  @override
  Future<Result<T>> execute() async {
    if (_isExecuting) {
      return _lastResult ?? const Error(HeavyweightException('Command already executing'));
    }
    
    _setExecuting(true);
    
    try {
      final result = _action();
      _setResult(result);
      return result;
    } catch (e) {
      final error = Error<T>(e is Exception ? e : Exception(e.toString()));
      _setResult(error);
      return error;
    } finally {
      _setExecuting(false);
    }
  }
}

/// Sync command with one parameter
class SyncCommand1<P, T> extends Command<T> {
  final Result<T> Function(P parameter) _action;
  
  SyncCommand1(this._action);
  
  @override
  Future<Result<T>> execute() async {
    throw UnsupportedError('Use executeWith(parameter) for SyncCommand1');
  }
  
  /// Execute the command with a parameter
  Future<Result<T>> executeWith(P parameter) async {
    if (_isExecuting) {
      return _lastResult ?? const Error(HeavyweightException('Command already executing'));
    }
    
    _setExecuting(true);
    
    try {
      final result = _action(parameter);
      _setResult(result);
      return result;
    } catch (e) {
      final error = Error<T>(e is Exception ? e : Exception(e.toString()));
      _setResult(error);
      return error;
    } finally {
      _setExecuting(false);
    }
  }
}

/// Mixin for ViewModels that use commands
mixin CommandMixin on ChangeNotifier {
  final List<Command> _commands = [];
  
  /// Register a command for automatic disposal
  T registerCommand<T extends Command>(T command) {
    _commands.add(command);
    return command;
  }
  
  /// Dispose all registered commands
  @override
  void dispose() {
    for (final command in _commands) {
      command.dispose();
    }
    _commands.clear();
    super.dispose();
  }
}