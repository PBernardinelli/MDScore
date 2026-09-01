import 'package:flutter/material.dart';

import '../models/game_state.dart';

class RoundHistoryScreen extends StatefulWidget {
  const RoundHistoryScreen({
    super.key,
    required this.playerNames,
    required this.rounds,
  });

  final List<String> playerNames;
  final List<RoundResult> rounds;
  @override
  State<RoundHistoryScreen> createState() => _RoundHistoryScreenState();
}

class _RoundHistoryScreenState extends State<RoundHistoryScreen> {
  int? _selectedRound;

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
          child: widget.rounds.isEmpty
              ? _buildEmpty(context)
              : _buildHistory(context),
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
    final orderedRounds = List<RoundResult>.from(widget.rounds)
      ..sort((a, b) => b.round.compareTo(a.round));

    final totals = List<int>.filled(widget.playerNames.length, 0);

    for (final round in orderedRounds) {
      for (
        var index = 0;
        index < widget.playerNames.length && index < round.scores.length;
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
            showCheckboxColumn: false,
            columns: [
              const DataColumn(
                label: Text(
                  'ROUND',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              ...widget.playerNames.map(
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
                  selected: _selectedRound == roundResult.round,
                  onSelectChanged: (_) {
                    setState(() {
                      _selectedRound = roundResult.round;
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Round ${roundResult.round} selected.'),
                      ),
                    );
                  },

                  cells: [
                    DataCell(
                      Text(
                        '${roundResult.round}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    ...List<DataCell>.generate(widget.playerNames.length, (
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

        const SizedBox(height: 20),

        SizedBox(
          height: 46,
          child: FilledButton.icon(
            onPressed: _selectedRound == null
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Edit round?'),
                          content: Text(
                            'Do you want to edit Round $_selectedRound?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('CANCEL'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('EDIT'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed != true) return;
                    if (!context.mounted) return;
                    Navigator.of(context).pop(_selectedRound);
                  },

            icon: const Icon(Icons.undo),
            label: const Text(
              'EDIT ROUND',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
