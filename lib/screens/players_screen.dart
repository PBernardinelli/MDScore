import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../services/game_storage.dart';
import 'score_screen.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({
    super.key,
    required this.playerCount,
    required this.gameName,
  });

  final int playerCount;
  final String gameName;

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  late final List<TextEditingController> _controllers;
  bool _startingGame = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.playerCount,
      (index) => TextEditingController(text: 'Player ${index + 1}'),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _startGame() async {
    if (_startingGame) return;

    final names = _controllers
        .map((controller) => controller.text.trim())
        .toList(growable: false);

    if (names.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name for every player.')),
      );
      return;
    }

    setState(() => _startingGame = true);

    final game = GameState.newGame(
      gameName: widget.gameName,
      playerNames: names,
    );

    try {
      await GameStorage.saveCurrentGame(game);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ScoreScreen(initialGame: game),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _startingGame = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start the game.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PLAYERS',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/dom_mino.png',
                      height: 58,
                      width: 58,
                      fit: BoxFit.contain,
                      semanticLabel: 'Dom Minó',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Who is playing?',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'You can change the suggested names before starting.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...List.generate(widget.playerCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _controllers[index],
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Player ${index + 1}',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _startingGame ? null : _startGame,
                  icon: _startingGame
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _startingGame ? 'STARTING...' : 'START GAME',
                    style: const TextStyle(
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
      ),
    );
  }
}
