import 'regular_players_screen.dart';

import 'package:flutter/material.dart';

import '../services/settings_storage.dart';
import '../services/game_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onTextSizeChanged});

  static const routeName = '/settings';

  final VoidCallback? onTextSizeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _confirmNewGame = true;
  String _textSize = 'normal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final confirmNewGame = await SettingsStorage.loadConfirmNewGame();

    final soundEnabled = await SettingsStorage.loadSoundEnabled();

    final textSize = await SettingsStorage.loadTextSize();

    if (!mounted) return;
    setState(() {
      _confirmNewGame = confirmNewGame;
      _soundEnabled = soundEnabled;
      _textSize = textSize;
    });
  }

  Future<void> _clearGameHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Game History?'),
          content: const Text(
            'All finished games will be permanently deleted.\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await GameStorage.clearFinishedGames();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Game history cleared.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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

              _sectionTitle(context, 'PLAYERS'),
              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.people_outline_rounded),
                  title: const Text(
                    'Regular Players',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Save frequently used player names'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RegularPlayersScreen(),
                      ),
                    );
                  },
                ),
              ),
              _sectionTitle(context, 'DISPLAY'),
              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.text_fields_rounded),
                  title: const Text(
                    'Text Size',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(_textSize == 'large' ? 'Large' : 'Normal'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _selectTextSize,
                ),
              ),
              const SizedBox(height: 22),

              _sectionTitle(context, 'PREFERENCES'),
              const SizedBox(height: 10),

              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _soundEnabled,

                      onChanged: (value) async {
                        setState(() => _soundEnabled = value);

                        await SettingsStorage.saveSoundEnabled(value);
                      },

                      title: const Text(
                        'Sounds',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text('Play subtle confirmation sounds'),
                      secondary: const Icon(Icons.volume_up_outlined),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _confirmNewGame,
                      onChanged: (value) async {
                        setState(() => _confirmNewGame = value);

                        await SettingsStorage.saveConfirmNewGame(value);
                      },

                      title: const Text(
                        'Confirm New Game',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Prevent accidental game replacement',
                      ),
                      secondary: const Icon(Icons.shield_outlined),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _sectionTitle(context, 'DATA'),
              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text(
                    'Clear Game History',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Delete all finished games'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _clearGameHistory,
                ),
              ),
              const SizedBox(height: 22),

              _sectionTitle(context, 'ABOUT'),
              const SizedBox(height: 10),

              const Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text(
                        'MD Score',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('Mexican Dominoes Score'),
                      trailing: Text(
                        'Dom Minó',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.tag_rounded),
                      title: Text(
                        'Version',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(
                        '0.48',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.7,
      ),
    );
  }

  Future<void> _selectTextSize() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Text Size'),

          children: [
            ListTile(
              leading: Icon(
                _textSize == 'normal'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: const Text('Normal'),
              onTap: () {
                Navigator.of(dialogContext).pop('normal');
              },
            ),
            ListTile(
              leading: Icon(
                _textSize == 'large'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: const Text('Large'),
              onTap: () {
                Navigator.of(dialogContext).pop('large');
              },
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    await SettingsStorage.saveTextSize(selected);

    if (!mounted) return;

    setState(() {
      _textSize = selected;
    });

    widget.onTextSizeChanged?.call();
  }
}
