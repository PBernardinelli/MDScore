import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
    required this.gameName,
    required this.playerNames,
  });

  final String gameName;
  final List<String> playerNames;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int _round = 12;
  bool _gameFinished = false;

  late final List<int> _totals;
  late List<TextEditingController> _roundControllers;

  @override
  void initState() {
    super.initState();
    _totals = List.filled(widget.playerNames.length, 0);
    _roundControllers = _newControllers();
  }

  List<TextEditingController> _newControllers() {
    return List.generate(
      widget.playerNames.length,
      (_) => TextEditingController(),
    );
  }

  void _disposeControllers() {
    for (final controller in _roundControllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _saveRound() {
    if (_gameFinished) return;

    final values = <int>[];

    for (final controller in _roundControllers) {
      final value = int.tryParse(controller.text.trim());
      if (value == null || value < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter every score before saving.')),
        );
        return;
      }
      values.add(value);
    }

    final savedRound = _round;

    setState(() {
      for (var index = 0; index < values.length; index++) {
        _totals[index] += values[index];
      }

      _disposeControllers();

      if (_round == 0) {
        _roundControllers = <TextEditingController>[];
        _gameFinished = true;
      } else {
        _round--;
        _roundControllers = _newControllers();
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Round $savedRound saved.')));
  }

  List<int> get _rankingIndexes {
    final indexes = List<int>.generate(
      widget.playerNames.length,
      (index) => index,
    );
    indexes.sort((a, b) => _totals[a].compareTo(_totals[b]));
    return indexes;
  }

  List<int> get _winnerIndexes {
    if (_totals.isEmpty) return const [];
    final lowestTotal = _totals.reduce((a, b) => a < b ? a : b);
    return List<int>.generate(
      widget.playerNames.length,
      (index) => index,
    ).where((index) => _totals[index] == lowestTotal).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.gameName.isEmpty ? 'Current Game' : widget.gameName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'DM',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _gameFinished
                ? _GameFinishedView(
                    playerNames: widget.playerNames,
                    totals: _totals,
                    rankingIndexes: _rankingIndexes,
                    winnerIndexes: _winnerIndexes,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Round $_round',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          Text(
                            '${13 - _round} of 13',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _ScoreHeader(),
                      const SizedBox(height: 8),
                      ...List.generate(widget.playerNames.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ScoreRow(
                            playerName: widget.playerNames[index],
                            total: _totals[index],
                            controller: _roundControllers[index],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _saveRound,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_round == 0 ? 'Finish Game' : 'Save Round'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GameFinishedView extends StatelessWidget {
  const _GameFinishedView({
    required this.playerNames,
    required this.totals,
    required this.rankingIndexes,
    required this.winnerIndexes,
  });

  final List<String> playerNames;
  final List<int> totals;
  final List<int> rankingIndexes;
  final List<int> winnerIndexes;

  @override
  Widget build(BuildContext context) {
    final winnerNames = winnerIndexes
        .map((index) => playerNames[index])
        .join(', ');
    final winningTotal = winnerIndexes.isEmpty
        ? 0
        : totals[winnerIndexes.first];
    final isTie = winnerIndexes.length > 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.accent,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  'Game Finished',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  isTie ? 'Tie' : 'Winner',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  winnerNames,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$winningTotal points',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Final Ranking', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...List.generate(rankingIndexes.length, (position) {
          final playerIndex = rankingIndexes[position];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${position + 1}')),
              title: Text(
                playerNames[playerIndex],
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Text(
                '${totals[playerIndex]}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          icon: const Icon(Icons.home_outlined),
          label: const Text('Back to Home'),
        ),
      ],
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text('Player')),
          Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('Round', textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.playerName,
    required this.total,
    required this.controller,
  });

  final String playerName;
  final int total;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                playerName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '$total',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '0',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
