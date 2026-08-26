import 'package:flutter/material.dart';

import '../models/game_state.dart';

class RoundHistoryScreen extends StatelessWidget {
  const RoundHistoryScreen({
    super.key,
    required this.playerNames,
    required this.rounds,
  });

  final List<String> playerNames;
  final List<RoundResult> rounds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ROUND HISTORY',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: rounds.isEmpty ? _buildEmpty(context) : _buildHistory(context),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No rounds saved yet.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final orderedRounds = List<RoundResult>.from(rounds)
      ..sort((a, b) => b.round.compareTo(a.round));

    final totals = List<int>.filled(playerNames.length, 0);

    for (final round in orderedRounds) {
      for (
        var index = 0;
        index < playerNames.length && index < round.scores.length;
        index++
      ) {
        totals[index] += round.scores[index];
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
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
              ...playerNames.map(
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
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    ...List<DataCell>.generate(playerNames.length, (index) {
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
                  ...totals.map(
                    (value) => DataCell(
                      Text(
                        '$value',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
