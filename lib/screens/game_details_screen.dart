import 'package:flutter/material.dart';

import '../models/game_state.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key, required this.game});

  final GameState game;

  String _dateText() {
    final date = game.updatedAt;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$month/$day/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final orderedRounds = List<RoundResult>.from(game.rounds)
      ..sort((a, b) => b.round.compareTo(a.round));

    final rankingIndexes = List<int>.generate(
      game.playerNames.length,
      (index) => index,
    );

    int zeroCount(int playerIndex) {
      return game.rounds
          .where(
            (round) =>
                playerIndex < round.scores.length &&
                round.scores[playerIndex] == 0,
          )
          .length;
    }

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

    rankingIndexes.sort((a, b) {
      final totalComparison = game.totals[a].compareTo(game.totals[b]);

      if (totalComparison != 0) {
        return totalComparison;
      }

      final zeroComparison = zeroCount(b).compareTo(zeroCount(a));

      if (zeroComparison != 0) {
        return zeroComparison;
      }

      return worstRound(a).compareTo(worstRound(b));
    });

    final firstIndex = rankingIndexes.first;

    final winnerIndexes = rankingIndexes.where((index) {
      return game.totals[index] == game.totals[firstIndex] &&
          zeroCount(index) == zeroCount(firstIndex) &&
          worstRound(index) == worstRound(firstIndex);
    }).toList();

    final winnerNames = winnerIndexes
        .map((index) => game.playerNames[index])
        .join(', ');

    final isTie = winnerIndexes.length > 1;
    final winningTotal = game.totals[firstIndex];



    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GAME DETAILS',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                game.gameName.isEmpty ? 'Finished game' : game.gameName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(_dateText(), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 42,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTie ? 'Tie' : 'Winner',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              winnerNames,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Text(
                              '$winningTotal points',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),


              Text(
                'FINAL RANKING',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),


              ...List.generate(rankingIndexes.length, (position) {
                final playerIndex = rankingIndexes[position];
                final total = game.totals[playerIndex];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${position + 1}'),
                    ),
                    title: Text(
                      game.playerNames[playerIndex],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              Text(
                'ROUND HISTORY',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(
                      label: Text(
                        'ROUND',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    ...game.playerNames.map(
                      (name) => DataColumn(
                        label: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...orderedRounds.map((roundResult) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${roundResult.round}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          ...List<DataCell>.generate(game.playerNames.length, (
                            index,
                          ) {
                            final value = index < roundResult.scores.length
                                ? roundResult.scores[index]
                                : 0;

                            return DataCell(
                              Text(
                                '$value',
                                style: TextStyle(
                                  fontWeight: value == 0
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }),

                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            'TOTAL',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        ...List<DataCell>.generate(game.playerNames.length, (
                          index,
                        ) {
                          final total = index < game.totals.length
                              ? game.totals[index]
                              : 0;

                          return DataCell(
                            Text(
                              '$total',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        }),
                      ],
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
}
