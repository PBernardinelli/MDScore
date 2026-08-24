import 'dart:convert';

class RoundResult {
  const RoundResult({required this.round, required this.scores});

  final int round;
  final List<int> scores;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'round': round, 'scores': scores};
  }

  factory RoundResult.fromMap(Map<String, dynamic> map) {
    return RoundResult(
      round: map['round'] as int,
      scores: List<int>.from(map['scores'] as List<dynamic>),
    );
  }
}

class GameState {
  const GameState({
    required this.gameName,
    required this.playerNames,
    required this.round,
    required this.totals,
    required this.currentScores,
    required this.createdAt,
    required this.updatedAt,
    this.lastSavedRound,
    this.lastRoundScores,
    this.rounds = const <RoundResult>[],
  });

  final String gameName;
  final List<String> playerNames;
  final int round;
  final List<int> totals;
  final List<String> currentScores;
  final List<RoundResult> rounds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? lastSavedRound;
  final List<int>? lastRoundScores;

  factory GameState.newGame({
    required String gameName,
    required List<String> playerNames,
  }) {
    final now = DateTime.now();
    return GameState(
      gameName: gameName,
      playerNames: List<String>.from(playerNames),
      round: 12,
      totals: List<int>.filled(playerNames.length, 0),
      currentScores: List<String>.filled(playerNames.length, ''),
      rounds: const <RoundResult>[],
      createdAt: now,
      updatedAt: now,
    );
  }

  GameState copyWith({
    String? gameName,
    List<String>? playerNames,
    int? round,
    List<int>? totals,
    List<String>? currentScores,
    List<RoundResult>? rounds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? lastSavedRound,
    List<int>? lastRoundScores,
    bool clearLastRound = false,
  }) {
    return GameState(
      gameName: gameName ?? this.gameName,
      playerNames: playerNames ?? List<String>.from(this.playerNames),
      round: round ?? this.round,
      totals: totals ?? List<int>.from(this.totals),
      currentScores: currentScores ?? List<String>.from(this.currentScores),
      rounds: rounds ?? List<RoundResult>.from(this.rounds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSavedRound: clearLastRound
          ? null
          : lastSavedRound ?? this.lastSavedRound,
      lastRoundScores: clearLastRound
          ? null
          : lastRoundScores ??
                (this.lastRoundScores == null
                    ? null
                    : List<int>.from(this.lastRoundScores!)),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gameName': gameName,
      'playerNames': playerNames,
      'round': round,
      'totals': totals,
      'currentScores': currentScores,
      'rounds': rounds.map((round) => round.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSavedRound': lastSavedRound,
      'lastRoundScores': lastRoundScores,
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    final names = List<String>.from(map['playerNames'] as List<dynamic>);
    final totals = List<int>.from(map['totals'] as List<dynamic>);
    final rawScores = map['currentScores'] as List<dynamic>?;
    final rawLastScores = map['lastRoundScores'] as List<dynamic>?;
    final rawRounds = map['rounds'] as List<dynamic>?;

    return GameState(
      gameName: map['gameName'] as String? ?? '',
      playerNames: names,
      round: map['round'] as int? ?? 12,
      totals: totals,
      currentScores: rawScores == null
          ? List<String>.filled(names.length, '')
          : List<String>.from(rawScores),
      rounds: rawRounds == null
          ? const <RoundResult>[]
          : rawRounds
                .map(
                  (item) => RoundResult.fromMap(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      lastSavedRound: map['lastSavedRound'] as int?,
      lastRoundScores: rawLastScores == null
          ? null
          : List<int>.from(rawLastScores),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory GameState.fromJson(String source) {
    return GameState.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
