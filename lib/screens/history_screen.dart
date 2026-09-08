import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../services/game_storage.dart';
import 'game_details_screen.dart';

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

    // 1º critério: menor total
    final lowestTotal = game.totals.reduce((a, b) => a < b ? a : b);

    var candidates =
        List<int>.generate(game.playerNames.length, (index) => index)
            .where(
              (index) =>
                  index < game.totals.length &&
                  game.totals[index] == lowestTotal,
            )
            .toList();

    if (candidates.isEmpty) return 'No result';

    // 2º critério: maior quantidade de rounds com zero
    int zeroCount(int playerIndex) {
      return game.rounds
          .where(
            (round) =>
                playerIndex < round.scores.length &&
                round.scores[playerIndex] == 0,
          )
          .length;
    }

    if (candidates.length > 1) {
      final mostZeros = candidates
          .map(zeroCount)
          .reduce((a, b) => a > b ? a : b);

      candidates = candidates
          .where((index) => zeroCount(index) == mostZeros)
          .toList();
    }

    // 3º critério: menor pior rodada
    int worstRound(int playerIndex) {
      var worst = 0;

      for (final round in game.rounds) {
        if (playerIndex < round.scores.length) {
          final score = round.scores[playerIndex];

          if (score > worst) {
            worst = score;
          }
        }
      }

      return worst;
    }

    if (candidates.length > 1) {
      final lowestWorstRound = candidates
          .map(worstRound)
          .reduce((a, b) => a < b ? a : b);

      candidates = candidates
          .where((index) => worstRound(index) == lowestWorstRound)
          .toList();
    }

    final winners = candidates.map((index) => game.playerNames[index]).toList();

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

  Future<void> _deleteGame(GameState game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Game?'),
          content: Text(
            'Delete "${_gameTitle(game)}" from history?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await GameStorage.deleteFinishedGame(game);

    if (!mounted) return;

    await _loadHistory();
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GameDetailsScreen(game: game),
                  ),
                );
              },

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

              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Delete game',
                onPressed: () => _deleteGame(game),
              ),

              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
