import 'package:flutter/material.dart';
import '../../core/routes.dart';

class ScreenIndex extends StatelessWidget {
  const ScreenIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = ScreenRegistry.all.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Scaffold(
      appBar: AppBar(title: const Text('SCREEN INDEX')),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final e = entries[i];
          return ListTile(
            title: Text(e.key),
            subtitle: const Text('Tap to open'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: e.value,
                settings: RouteSettings(name: e.key),
              ),
            ),
          );
        },
      ),
    );
  }
}
