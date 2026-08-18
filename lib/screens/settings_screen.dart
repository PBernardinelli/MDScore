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
      appBar: AppBar(
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            children: [
              Center(
                child: Image.asset(
                  'assets/images/dom_mino.png',
                  height: 105,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'PREFERENCES',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() => _soundEnabled = value);
                      },
                      title: const Text('Sounds', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Play subtle confirmation sounds'),
                      secondary: const Icon(Icons.volume_up_outlined),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _confirmNewGame,
                      onChanged: (value) {
                        setState(() => _confirmNewGame = value);
                      },
                      title: const Text('Confirm New Game', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Prevent accidental game replacement'),
                      secondary: const Icon(Icons.shield_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'ABOUT',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('MD Score'),
                  subtitle: const Text('Mexican Dominoes Score'),
                  trailing: const Text(
                    'Dom Minó',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
