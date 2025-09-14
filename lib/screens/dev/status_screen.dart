import 'package:flutter/material.dart';
import '../../core/system_config.dart';
import '../../core/log_config.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class DevStatusScreen extends StatelessWidget {
  const DevStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = SystemConfig.instance;
    final shortOn = cfg.isLoaded && cfg.debugShortRestEnabled;
    final shortSecs = cfg.debugShortRestSeconds;
    final appState = context.read<AppStateProvider>().appState;
    final dbg = appState.nextOnboardingRouteDebug();

    return Scaffold(
      appBar: AppBar(title: const Text('DEV STATUS')),
      backgroundColor: const Color(0xFF111111),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Debug Flags', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Short Rest: ${shortOn ? 'ENABLED ($shortSecs s)' : 'OFF'}', style: const TextStyle(color: Colors.white70)),
                ),
                Switch(
                  value: shortOn,
                  onChanged: (v) {
                    cfg.setDebugShortRestOverride(enabled: v, seconds: shortSecs);
                    // force rebuild
                    (context as Element).markNeedsBuild();
                  },
                ),
                const SizedBox(width: 8),
                if (shortOn)
                  Row(
                    children: [
                      IconButton(
                        tooltip: '−5s',
                        onPressed: () {
                          final s = (shortSecs - 5).clamp(1, 60);
                          cfg.setDebugShortRestOverride(enabled: true, seconds: s);
                          (context as Element).markNeedsBuild();
                        },
                        icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
                      ),
                      Text('$shortSecs s', style: const TextStyle(color: Colors.white70)),
                      IconButton(
                        tooltip: '+5s',
                        onPressed: () {
                          final s = (shortSecs + 5).clamp(1, 300);
                          cfg.setDebugShortRestOverride(enabled: true, seconds: s);
                          (context as Element).markNeedsBuild();
                        },
                        icon: const Icon(Icons.add, color: Colors.white70, size: 18),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Logging', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Muted: ${LogConfig.mutes()}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Cooldowns: ${LogConfig.cooldownsMs()}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Sampling: ${LogConfig.sampling()}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('Cooldowns and sampling are loaded from system_config.json', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 24),
            const Text('Onboarding Route', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Next: ${dbg.nextRoute ?? '/app'}', style: const TextStyle(color: Colors.white70)),
            Text('Unmet: ${dbg.unmet.isEmpty ? '—' : dbg.unmet.join(', ')}', style: const TextStyle(color: Colors.white70)),
            Text('Units: ${dbg.fields['unitPreference']}', style: const TextStyle(color: Colors.white70)),
            Text('Stats: ${(dbg.fields['age']!=null && dbg.fields['weightKg']!=null && dbg.fields['heightCm']!=null) ? 'OK' : 'MISSING'}', style: const TextStyle(color: Colors.white70)),
            Text('Rest Days: ${dbg.fields['restDays']}', style: const TextStyle(color: Colors.white70)),
            Text('Days/Week: ${dbg.fields['daysPerWeek']}', style: const TextStyle(color: Colors.white70)),
            Text('Session Duration: ${dbg.fields['sessionDurationMin']} min', style: const TextStyle(color: Colors.white70)),
            Text('Manifesto: ${(dbg.fields['manifestoCommitted'] == true) ? 'YES' : 'NO'}', style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
