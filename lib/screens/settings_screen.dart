import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _confirmNewGame = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() => _soundEnabled = value);
                      },
                      title: const Text('Sounds'),
                      subtitle: const Text('Play subtle confirmation sounds'),
                      secondary: const Icon(Icons.volume_up_outlined),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _confirmNewGame,
                      onChanged: (value) {
                        setState(() => _confirmNewGame = value);
                      },
                      title: const Text('Confirm New Game'),
                      subtitle: const Text('Prevent accidental game replacement'),
                      secondary: const Icon(Icons.shield_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('MD Score'),
                  subtitle: const Text('Version 0.2.0 • Navigation package'),
                  trailing: const Text('Don Minó'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
