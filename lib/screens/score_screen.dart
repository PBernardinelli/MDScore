// MD Score
// Version: V0.34
// File: score_screen.dart
// Date: 2026-07-20

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../models/game_state.dart';
import '../services/game_storage.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
    required this.initialGame,
  });

  final GameState initialGame;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  late int _round;
  int? _activePlayerIndex;
  bool _gameFinished = false;
  bool _savingRound = false;

  late final String _gameName;
  late final List<String> _playerNames;
  late final DateTime _createdAt;
  late final List<int> _totals;
  late List<TextEditingController> _roundControllers;
  late List<FocusNode> _focusNodes;

  Timer? _autoSaveTimer;
  Timer? _persistTimer;
  Future<void> _storageQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    final game = widget.initialGame;
    _gameName = game.gameName;
    _playerNames = List<String>.from(game.playerNames);
    _createdAt = game.createdAt;
    _round = game.round;
    _totals = List<int>.from(game.totals);
    _createRoundInputs(initialScores: game.currentScores);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) {
        final firstEmpty = _roundControllers.indexWhere(
          (controller) => controller.text.trim().isEmpty,
        );
        _focusNodes[firstEmpty < 0 ? 0 : firstEmpty].requestFocus();
      }
    });
  }

  void _createRoundInputs({List<String>? initialScores}) {
    _roundControllers = List.generate(
      _playerNames.length,
      (index) => TextEditingController(
        text: initialScores != null && index < initialScores.length
            ? initialScores[index]
            : '',
      ),
    );

    _focusNodes = List.generate(_playerNames.length, (index) {
      final node = FocusNode();
      node.addListener(() {
        if (!mounted) return;
        if (node.hasFocus) {
          setState(() => _activePlayerIndex = index);
        } else if (_activePlayerIndex == index) {
          setState(() => _activePlayerIndex = null);
        }
      });
      return node;
    });
  }

  void _disposeRoundInputs() {
    for (final controller in _roundControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _persistTimer?.cancel();
    _disposeRoundInputs();
    super.dispose();
  }

  GameState _currentGameState() {
    return GameState(
      gameName: _gameName,
      playerNames: List<String>.from(_playerNames),
      round: _round,
      totals: List<int>.from(_totals),
      currentScores: _roundControllers
          .map((controller) => controller.text.trim())
          .toList(growable: false),
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void _queueStorage(Future<void> Function() operation) {
    _storageQueue = _storageQueue.then((_) => operation()).catchError((_) {});
  }

  void _scheduleCurrentGameSave() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted || _gameFinished || _savingRound) return;
      final game = _currentGameState();
      _queueStorage(() => GameStorage.saveCurrentGame(game));
    });
  }

  bool get _allScoresEntered {
    return _roundControllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
  }

  void _handleScoreChanged(int index, String text) {
    _scheduleCurrentGameSave();
    _autoSaveTimer?.cancel();

    if (_allScoresEntered) {
      // The small delay allows the marker to finish typing a 2- or 3-digit score.
      _autoSaveTimer = Timer(const Duration(milliseconds: 900), _saveRound);
    }
  }

  void _handleSubmitted(int index) {
    _autoSaveTimer?.cancel();

    if (_allScoresEntered) {
      _saveRound();
      return;
    }

    for (var offset = 1; offset <= _focusNodes.length; offset++) {
      final nextIndex = (index + offset) % _focusNodes.length;
      if (_roundControllers[nextIndex].text.trim().isEmpty) {
        _focusNodes[nextIndex].requestFocus();
        return;
      }
    }
  }

  Future<void> _saveRound() async {
    if (_gameFinished || _savingRound) return;

    _autoSaveTimer?.cancel();
    _persistTimer?.cancel();

    final values = <int>[];

    for (var index = 0; index < _roundControllers.length; index++) {
      final value = int.tryParse(_roundControllers[index].text.trim());
      if (value == null || value < 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enter the score for ${_playerNames[index]}.')),
        );
        _focusNodes[index].requestFocus();
        return;
      }
      values.add(value);
    }

    setState(() => _savingRound = true);

    final savedRound = _round;
    final finishesGame = _round == 0;

    setState(() {
      for (var index = 0; index < values.length; index++) {
        _totals[index] += values[index];
      }

      _disposeRoundInputs();
      _activePlayerIndex = null;

      if (finishesGame) {
        _roundControllers = <TextEditingController>[];
        _focusNodes = <FocusNode>[];
        _gameFinished = true;
      } else {
        _round--;
        _createRoundInputs();
      }
    });

    if (finishesGame) {
      _queueStorage(GameStorage.clearCurrentGame);
    } else {
      final game = _currentGameState();
      _queueStorage(() => GameStorage.saveCurrentGame(game));
    }

    if (!mounted) return;
    setState(() => _savingRound = false);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Round $savedRound saved.')),
    );

    if (!_gameFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNodes.isNotEmpty) {
          _focusNodes.first.requestFocus();
        }
      });
    }
  }

  List<int> get _rankingIndexes {
    final indexes = List<int>.generate(_playerNames.length, (index) => index);
    indexes.sort((a, b) => _totals[a].compareTo(_totals[b]));
    return indexes;
  }

  List<int> get _winnerIndexes {
    if (_totals.isEmpty) return const [];
    final lowestTotal = _totals.reduce((a, b) => a < b ? a : b);
    return List<int>.generate(
      _playerNames.length,
      (index) => index,
    ).where((index) => _totals[index] == lowestTotal).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = _gameName.isEmpty ? 'Current Game' : _gameName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    playerNames: _playerNames,
                    totals: _totals,
                    rankingIndexes: _rankingIndexes,
                    winnerIndexes: _winnerIndexes,
                  )
                : _buildScoreView(context),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Round $_round',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Text(
              '${13 - _round} of 13',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 10),
        const _ScoreHeader(),
        const SizedBox(height: 5),
        ...List.generate(_playerNames.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: _ScoreRow(
              playerName: _playerNames[index],
              total: _totals[index],
              controller: _roundControllers[index],
              focusNode: _focusNodes[index],
              isActive: _activePlayerIndex == index,
              isLast: index == _playerNames.length - 1,
              autofocus: index == 0,
              onChanged: (value) => _handleScoreChanged(index, value),
              onSubmitted: () => _handleSubmitted(index),
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: FilledButton.icon(
            onPressed: _savingRound ? null : _saveRound,
            icon: _savingRound
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _savingRound
                  ? 'Saving...'
                  : _round == 0
                      ? 'Finish Game'
                      : 'Save Round',
            ),
          ),
        ),
      ],
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
    final winnerNames = winnerIndexes.map((index) => playerNames[index]).join(', ');
    final winningTotal = winnerIndexes.isEmpty ? 0 : totals[winnerIndexes.first];
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
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
    final style = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text('Player', style: style)),
          Expanded(
            flex: 2,
            child: Text('Total', textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 3,
            child: Text('Round', textAlign: TextAlign.center, style: style),
          ),
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
    required this.focusNode,
    required this.isActive,
    required this.isLast,
    required this.autofocus,
    required this.onChanged,
    required this.onSubmitted,
  });

  final String playerName;
  final int total;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final bool isLast;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accent.withValues(alpha: 0.10)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppTheme.accent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textInputAction:
                      isLast ? TextInputAction.done : TextInputAction.next,
                  textAlign: TextAlign.center,
                  onTap: () {
                    controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: controller.text.length,
                    );
                  },
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmitted(),
                  decoration: const InputDecoration(
                    hintText: '0',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
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
