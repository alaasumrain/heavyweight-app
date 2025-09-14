import '../fortress/engine/models/set_data.dart';
import 'system_config.dart';

class MetricsSummary {
  final double adherenceOverall; // percent
  final Map<int, double> adherenceWindow; // sessions window -> percent
  final bool plateauDetected;
  final int sessionsCount;

  MetricsSummary({
    required this.adherenceOverall,
    required this.adherenceWindow,
    required this.plateauDetected,
    required this.sessionsCount,
  });
}

class SystemMetricsService {
  static MetricsSummary compute(List<SetData> history) {
    if (!SystemConfig.instance.isLoaded) {
      SystemConfig.instance.load();
    }
    final metricsCfg = (SystemConfig.instance as dynamic)._data?['metrics'] as Map<String, dynamic>?;
    final windows = (metricsCfg?['adherenceWindows'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [3, 6, 12];
    final plateau = metricsCfg?['plateau'] as Map<String, dynamic>?;
    final plateauWindow = (plateau?['windowSessions'] as num?)?.toInt() ?? 6;
    final plateauMinProgress = (plateau?['minProgressPercent'] as num?)?.toDouble() ?? 1.0;

    if (history.isEmpty) {
      return MetricsSummary(adherenceOverall: 0, adherenceWindow: {}, plateauDetected: false, sessionsCount: 0);
    }

    // Group sets by session date
    final sessions = <String, List<SetData>>{};
    for (final s in history) {
      final key = '${s.timestamp.year}-${s.timestamp.month}-${s.timestamp.day}';
      (sessions[key] ??= []).add(s);
    }
    final sessionList = sessions.values.toList()
      ..sort((a, b) => a.first.timestamp.compareTo(b.first.timestamp));

    // Overall adherence
    final totalSets = history.length;
    final mandateSets = history.where((s) => s.metMandate).length;
    final overall = totalSets > 0 ? (mandateSets / totalSets) * 100 : 0.0;

    // Window adherence per number of sessions
    final windowResults = <int, double>{};
    for (final w in windows) {
      final lastSessions = sessionList.length >= w ? sessionList.sublist(sessionList.length - w) : sessionList;
      int wSets = 0;
      int wMandate = 0;
      for (final sess in lastSessions) {
        wSets += sess.length;
        wMandate += sess.where((s) => s.metMandate).length;
      }
      windowResults[w] = wSets > 0 ? (wMandate / wSets) * 100 : 0.0;
    }

    // Plateau detection: compare average load progression over plateauWindow sessions
    bool plateauDetected = false;
    if (sessionList.length >= plateauWindow) {
      // Simple proxy: average reps within mandate should trend up slightly or weight should progress; here we use reps*weight avg delta
      final last = sessionList.sublist(sessionList.length - plateauWindow);
      final firstHalf = last.sublist(0, (plateauWindow / 2).floor());
      final secondHalf = last.sublist((plateauWindow / 2).floor());
      double avg1 = _avgLoad(firstHalf);
      double avg2 = _avgLoad(secondHalf);
      final progressPercent = avg1 > 0 ? ((avg2 - avg1) / avg1) * 100 : 0.0;
      plateauDetected = progressPercent < plateauMinProgress;
    }

    return MetricsSummary(
      adherenceOverall: overall,
      adherenceWindow: windowResults,
      plateauDetected: plateauDetected,
      sessionsCount: sessionList.length,
    );
  }

  static double _avgLoad(List<List<SetData>> sessions) {
    if (sessions.isEmpty) return 0.0;
    double sum = 0;
    int count = 0;
    for (final sess in sessions) {
      for (final s in sess) {
        sum += s.weight * s.actualReps;
        count++;
      }
    }
    return count > 0 ? sum / count : 0.0;
  }
}

