import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/game_state.dart';
import '../services/game_storage.dart';
import '../services/settings_storage.dart';
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
    if (_currentGame != null) {
      final confirmNewGame = await SettingsStorage.loadConfirmNewGame();

      if (!mounted) return;

      if (confirmNewGame) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Game in progress'),
              content: const Text(
                'A game is already in progress.\n\n'
                'Starting a new game will discard the current game.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Start New Game'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) return;
      }

      await GameStorage.clearCurrentGame();

      if (!mounted) return;

      setState(() => _currentGame = null);
    }

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
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/dom_mino.png',
                    height: 145,
                    fit: BoxFit.contain,
                    semanticLabel: 'Dom Minó',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MD SCORE',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mexican Dominoes Score',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sports_esports_rounded,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _loading
                              ? const LinearProgressIndicator()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game == null
                                          ? 'No game in progress'
                                          : displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    if (game != null) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        'Round ${game.round}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: _openNewGame,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text(
                      'NEW GAME',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: game == null || _loading ? null : _resumeGame,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'RESUME GAME',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, HistoryScreen.routeName),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.history_rounded),
                    label: const Text(
                      'HISTORY',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, SettingsScreen.routeName),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF303030),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Presented by ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Dom Minó',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
