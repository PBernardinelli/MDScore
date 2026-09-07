import 'package:flutter/material.dart';

import '../services/settings_storage.dart';

class RegularPlayersScreen extends StatefulWidget {
  const RegularPlayersScreen({super.key});

  @override
  State<RegularPlayersScreen> createState() => _RegularPlayersScreenState();
}

class _RegularPlayersScreenState extends State<RegularPlayersScreen> {
  final List<TextEditingController> _controllers = List.generate(
    8,
    (_) => TextEditingController(),
  );

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await SettingsStorage.loadRegularPlayers();

    if (!mounted) return;

    for (var i = 0; i < players.length && i < 8; i++) {
      _controllers[i].text = players[i];
    }

    setState(() => _loading = false);
  }

  Future<void> _savePlayers() async {
    final players = _controllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    await SettingsStorage.saveRegularPlayers(players);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Regular players saved.')));
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REGULAR PLAYERS',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  children: [
                    Text(
                      'Enter the names of players who play frequently.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),

                    ...List.generate(8, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: _controllers[index],
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Player ${index + 1}',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _savePlayers,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(
                          'SAVE',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
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
