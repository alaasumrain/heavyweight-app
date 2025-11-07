import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../fortress/engine/workout_engine.dart';
import '../fortress/engine/models/set_data.dart';
import '../fortress/engine/storage/workout_repository_interface.dart';

/// Cache entry with TTL (time-to-live) support for persistent storage
class PersistentCacheEntry {
  final String data;
  final DateTime expiry;
  final String version;

  const PersistentCacheEntry({
    required this.data,
    required this.expiry,
    required this.version,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  Map<String, dynamic> toJson() => {
        'data': data,
        'expiry': expiry.toIso8601String(),
        'version': version,
      };

  static PersistentCacheEntry fromJson(Map<String, dynamic> json) {
    return PersistentCacheEntry(
      data: json['data'],
      expiry: DateTime.parse(json['expiry']),
      version: json['version'] ?? '1.0',
    );
  }
}

/// Cache entry with TTL (time-to-live) support for memory cache
class CacheEntry<T> {
  final T data;
  final DateTime expiry;

  const CacheEntry(this.data, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Global cache service with two-tier caching (memory + persistent) following Flutter best practices
/// L1 Cache: Memory-based for ultra-fast access
/// L2 Cache: SharedPreferences for persistence across app restarts
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // L1 Cache: Memory cache for fast access
  final Map<String, CacheEntry> _memoryCache = {};

  // L2 Cache: Persistent cache
  SharedPreferences? _prefs;

  // Automatic cleanup timer
  Timer? _cleanupTimer;

  /// Cache version for handling app updates
  static const String cacheVersion = '1.1';

  /// Cache keys for different data types
  static const String workoutHistoryKey = 'hw_workout_history';
  static const String performanceStatsKey = 'hw_performance_stats';
  static const String todaysWorkoutKey = 'hw_todays_workout';
  static const String lastSessionKey = 'hw_last_session';

  /// Default TTL durations
  static const Duration shortTTL =
      Duration(minutes: 5); // For frequently changing data
  static const Duration mediumTTL =
      Duration(minutes: 10); // For moderately changing data
  static const Duration longTTL =
      Duration(hours: 1); // For rarely changing data

  /// Initialize the cache service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _clearOutdatedCache();
    _startPeriodicCleanup();
  }

  /// Start periodic cleanup of expired cache entries (every 10 minutes)
  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      await clearExpired();
    });
  }

  /// Clear outdated cache entries on app updates
  Future<void> _clearOutdatedCache() async {
    final storedVersion = _prefs?.getString('cache_version') ?? '1.0';
    if (storedVersion != cacheVersion) {
      await _prefs?.clear();
      await _prefs?.setString('cache_version', cacheVersion);
    }
  }

  /// Get cached data using two-tier approach (memory first, then persistent)
  Future<T?> get<T>(String key) async {
    await initialize();

    // L1 Cache: Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return _decodeValue<T>(memoryEntry.data);
    } else if (memoryEntry != null) {
      _memoryCache.remove(key); // Remove expired entry
    }

    // L2 Cache: Check persistent cache
    final persistentData = _prefs?.getString(key);
    if (persistentData != null) {
      try {
        final cacheEntry =
            PersistentCacheEntry.fromJson(jsonDecode(persistentData));
        if (!cacheEntry.isExpired && cacheEntry.version == cacheVersion) {
          // Restore to memory cache for faster next access
          final decoded = jsonDecode(cacheEntry.data);
          final typed = _decodeValue<T>(decoded);
          _memoryCache[key] = CacheEntry(typed, cacheEntry.expiry);
          return typed;
        } else {
          // Remove expired or outdated persistent entry
          await _prefs?.remove(key);
        }
      } catch (e) {
        // Remove corrupted persistent entry
        await _prefs?.remove(key);
      }
    }

    return null;
  }

  /// Cache data with specified TTL in both memory and persistent storage
  Future<void> set<T>(String key, T data, Duration ttl) async {
    await initialize();

    final expiry = DateTime.now().add(ttl);

    final serializable = _encodeValue(data);

    // L1 Cache: Store in memory (keep decoded form for fast access)
    _memoryCache[key] = CacheEntry(_decodeValue<dynamic>(serializable), expiry);

    // L2 Cache: Store persistently
    final persistentEntry = PersistentCacheEntry(
      data: jsonEncode(serializable),
      expiry: expiry,
      version: cacheVersion,
    );
    await _prefs?.setString(key, jsonEncode(persistentEntry.toJson()));
  }

  /// Check if key exists and is not expired in either cache
  Future<bool> has(String key) async {
    await initialize();

    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return true;
    }

    // Check persistent cache
    final persistentData = _prefs?.getString(key);
    if (persistentData != null) {
      try {
        final cacheEntry =
            PersistentCacheEntry.fromJson(jsonDecode(persistentData));
        return !cacheEntry.isExpired && cacheEntry.version == cacheVersion;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  /// Invalidate specific cache key from both memory and persistent storage
  Future<void> invalidate(String key) async {
    await initialize();
    _memoryCache.remove(key);
    await _prefs?.remove(key);
  }

  /// Invalidate multiple cache keys
  Future<void> invalidateKeys(List<String> keys) async {
    await initialize();
    for (final key in keys) {
      _memoryCache.remove(key);
      await _prefs?.remove(key);
    }
  }

  /// Clear all cached data from both memory and persistent storage
  Future<void> clear() async {
    await initialize();
    _memoryCache.clear();
    // Clear only cache keys, preserve other SharedPreferences data
    final allKeys = _prefs?.getKeys() ?? <String>{};
    for (final key in allKeys) {
      if (key.startsWith('hw_') || key == 'cache_version') {
        await _prefs?.remove(key);
      }
    }
  }

  /// Clear expired entries from both caches
  Future<void> clearExpired() async {
    await initialize();

    // Clear expired memory entries
    final expiredMemoryKeys = <String>[];
    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredMemoryKeys.add(entry.key);
      }
    }
    for (final key in expiredMemoryKeys) {
      _memoryCache.remove(key);
    }

    // Clear expired persistent entries
    final allKeys = _prefs?.getKeys() ?? <String>{};
    for (final key in allKeys) {
      if (key.startsWith('hw_')) {
        final persistentData = _prefs?.getString(key);
        if (persistentData != null) {
          try {
            final cacheEntry =
                PersistentCacheEntry.fromJson(jsonDecode(persistentData));
            if (cacheEntry.isExpired || cacheEntry.version != cacheVersion) {
              await _prefs?.remove(key);
            }
          } catch (e) {
            await _prefs?.remove(key);
          }
        }
      }
    }
  }

  /// Get cache stats for debugging
  Future<Map<String, dynamic>> getStats() async {
    await initialize();
    await clearExpired(); // Clean up first

    final persistentCount = (_prefs?.getKeys() ?? <String>{})
        .where((key) => key.startsWith('hw_'))
        .length;

    return {
      'memoryEntries': _memoryCache.length,
      'persistentEntries': persistentCount,
      'memoryKeys': _memoryCache.keys.toList(),
      'cacheVersion': cacheVersion,
      'memoryStats': _memoryCache.map((key, value) => MapEntry(key, {
            'expiry': value.expiry.toIso8601String(),
            'isExpired': value.isExpired,
          })),
    };
  }

  /// Convenience methods for common cache invalidation scenarios

  /// Invalidate all workout-related caches (call after completing workout)
  Future<void> invalidateWorkoutData() async {
    await invalidateKeys([
      workoutHistoryKey,
      performanceStatsKey,
      todaysWorkoutKey,
      lastSessionKey,
    ]);
  }

  /// Invalidate only today's workout (call after generating new workout)
  Future<void> invalidateTodaysWorkout() async {
    await invalidate(todaysWorkoutKey);
  }

  /// Invalidate history-related caches (call after saving new sets)
  Future<void> invalidateHistory() async {
    await invalidateKeys([
      workoutHistoryKey,
      performanceStatsKey,
      lastSessionKey,
    ]);
  }

  /// Dispose of resources when cache service is no longer needed
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  dynamic _encodeValue(dynamic value) {
    if (value is DailyWorkout) {
      return {
        '_type': 'DailyWorkout',
        'data': value.toJson(),
      };
    }
    if (value is PerformanceStats) {
      return {
        '_type': 'PerformanceStats',
        'data': value.toJson(),
      };
    }
    if (value is WorkoutSession) {
      return {
        '_type': 'WorkoutSession',
        'data': value.toJson(),
      };
    }
    if (value is List<WorkoutSession>) {
      return {
        '_type': 'WorkoutSessionList',
        'data': value.map((e) => e.toJson()).toList(),
      };
    }
    // For primitives or already serializable structures leave as-is
    return {
      '_type': 'raw',
      'data': value,
    };
  }

  T? _decodeValue<T>(dynamic stored) {
    if (stored == null) return null;

    if (stored is Map && stored.containsKey('_type')) {
      final type = stored['_type'];
      final data = stored['data'];

      if (type == 'DailyWorkout' && data is Map<String, dynamic>) {
        return DailyWorkout.fromJson(data) as T;
      }
      if (type == 'PerformanceStats' && data is Map<String, dynamic>) {
        return PerformanceStats.fromJson(data) as T;
      }
      if (type == 'WorkoutSession' && data is Map<String, dynamic>) {
        return WorkoutSession.fromJson(data) as T;
      }
      if (type == 'WorkoutSessionList' && data is List) {
        final sessions = data
            .whereType<Map<String, dynamic>>()
            .map(WorkoutSession.fromJson)
            .toList();
        return sessions as T;
      }
      if (type == 'raw') {
        return data as T;
      }
    }

    // Fallback: attempt direct cast
    return stored as T;
  }
}
