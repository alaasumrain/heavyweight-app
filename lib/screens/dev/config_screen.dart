import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/system_config.dart';

class DevConfigScreen extends StatelessWidget {
  const DevConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = SystemConfig.instance;
    final data = cfg.snapshot();
    final jsonPretty = const JsonEncoder.withIndent('  ').convert(data);
    final warnings = cfg.warnings;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(title: const Text('EFFECTIVE CONFIG')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warnings.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.withValues(alpha: 0.15),
                  child: Text('WARNINGS: ${warnings.join(', ')}',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              const SizedBox(height: 12),
              Text(jsonPretty,
                  style: const TextStyle(
                      fontFamily: 'IBM Plex Mono',
                      fontSize: 12,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
