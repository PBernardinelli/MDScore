import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/game_state.dart';
import '../services/game_storage.dart';
import '../widgets/md_brand_header.dart';
import 'history_screen.dart';
import 'new_game_screen.dart';
import 'score_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameState? _currentGame;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentGame();
  }

  Future<void> _loadCurrentGame() async {
    final game = await GameStorage.loadCurrentGame();
    if (!mounted) return;
    setState(() {
      _currentGame = game;
      _loading = false;
    });
  }

  Future<void> _openNewGame() async {
    await Navigator.pushNamed(context, NewGameScreen.routeName);
    await _loadCurrentGame();
  }

  Future<void> _resumeGame() async {
    final game = await GameStorage.loadCurrentGame();
    if (!mounted) return;

    if (game == null) {
      setState(() => _currentGame = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no saved game to resume.')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ScoreScreen(initialGame: game)),
    );
    await _loadCurrentGame();
  }

  @override
  Widget build(BuildContext context) {
    final game = _currentGame;
    final displayName = game == null
        ? 'No game in progress'
        : game.gameName.trim().isEmpty
            ? 'Game in progress'
            : game.gameName;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              children: [
                const MDBrandHeader(),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready for the next round? Create a new game or continue your last match.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.sports_esports_rounded,
                              color: AppTheme.accent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _loading
                                  ? const LinearProgressIndicator()
                                  : Text(
                                      game == null
                                          ? displayName
                                          : '$displayName • Round ${game.round}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _openNewGame,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('New Game'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: game == null || _loading ? null : _resumeGame,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume Game'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    HistoryScreen.routeName,
                  ),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('History'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    SettingsScreen.routeName,
                  ),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Settings'),
                ),
                const SizedBox(height: 26),
                Text(
                  'Beautiful. Simple. Easy to use.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
