import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../services/game_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  List<GameState> _games = <GameState>[];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final games = await GameStorage.loadFinishedGames();
    if (!mounted) return;

    setState(() {
      _games = games;
      _loading = false;
    });
  }

  String _gameTitle(GameState game) {
    final name = game.gameName.trim();
    return name.isEmpty ? 'Finished game' : name;
  }

  String _winnerText(GameState game) {
    if (game.playerNames.isEmpty || game.totals.isEmpty) {
      return 'No result';
    }

    final lowestTotal = game.totals.reduce((a, b) => a < b ? a : b);
    final winners = <String>[];

    for (var index = 0;
        index < game.playerNames.length && index < game.totals.length;
        index++) {
      if (game.totals[index] == lowestTotal) {
        winners.add(game.playerNames[index]);
      }
    }

    if (winners.isEmpty) return 'No result';

    if (winners.length == 1) {
      return '${winners.first} won • $lowestTotal points';
    }

    return 'Tie: ${winners.join(', ')} • $lowestTotal points';
  }

  String _dateText(GameState game) {
    final date = game.updatedAt;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HISTORY',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _games.isEmpty
                  ? _buildEmptyHistory(context)
                  : _buildHistoryList(context),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
      children: [
        const SizedBox(height: 50),
        Center(
          child: Image.asset(
            'assets/images/dom_mino.png',
            height: 120,
            fit: BoxFit.contain,
            semanticLabel: 'Dom Minó',
          ),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 52,
                  color: Color(0xFF43A047),
                ),
                const SizedBox(height: 18),
                Text(
                  'No finished games yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your completed games will appear here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        itemCount: _games.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/dom_mino.png',
                    height: 58,
                    width: 58,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_games.length} finished ${_games.length == 1 ? 'game' : 'games'}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }

          final game = _games[index - 1];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                child: Icon(Icons.emoji_events_rounded),
              ),
              title: Text(
                _gameTitle(game),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '${game.playerNames.length} players • ${_dateText(game)}\n'
                  '${_winnerText(game)}',
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
