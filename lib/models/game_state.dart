import 'dart:convert';

class GameState {
  const GameState({
    required this.gameName,
    required this.playerNames,
    required this.round,
    required this.totals,
    required this.currentScores,
    required this.createdAt,
    required this.updatedAt,
  });

  final String gameName;
  final List<String> playerNames;
  final int round;
  final List<int> totals;
  final List<String> currentScores;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameState(
      gameName: gameName ?? this.gameName,
      playerNames: playerNames ?? List<String>.from(this.playerNames),
      round: round ?? this.round,
      totals: totals ?? List<int>.from(this.totals),
      currentScores:
          currentScores ?? List<String>.from(this.currentScores),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gameName': gameName,
      'playerNames': playerNames,
      'round': round,
      'totals': totals,
      'currentScores': currentScores,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    final names = List<String>.from(map['playerNames'] as List<dynamic>);
    final totals = List<int>.from(map['totals'] as List<dynamic>);
    final rawScores = map['currentScores'] as List<dynamic>?;

    return GameState(
      gameName: map['gameName'] as String? ?? '',
      playerNames: names,
      round: map['round'] as int? ?? 12,
      totals: totals,
      currentScores: rawScores == null
          ? List<String>.filled(names.length, '')
          : List<String>.from(rawScores),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory GameState.fromJson(String source) {
    return GameState.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
