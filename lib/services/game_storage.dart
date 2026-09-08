import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

class GameStorage {
  GameStorage._();

  static const String _currentGameKey = 'md_score.current_game.v1';
  static const String _finishedGamesKey = 'md_score.finished_games.v1';
  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static Future<void> saveCurrentGame(GameState game) async {
    await _preferences.setString(_currentGameKey, game.toJson());
  }

  static Future<GameState?> loadCurrentGame() async {
    final source = await _preferences.getString(_currentGameKey);
    if (source == null || source.isEmpty) return null;

    try {
      return GameState.fromJson(source);
    } catch (_) {
      await clearCurrentGame();
      return null;
    }
  }

  static Future<bool> hasCurrentGame() async {
    return (await loadCurrentGame()) != null;
  }

  static Future<void> clearCurrentGame() async {
    await _preferences.remove(_currentGameKey);
  }

  static Future<void> saveFinishedGame(GameState game) async {
    final saved =
        await _preferences.getStringList(_finishedGamesKey) ?? <String>[];

    await _preferences.setStringList(_finishedGamesKey, <String>[
      game.toJson(),
      ...saved,
    ]);
  }

  static Future<List<GameState>> loadFinishedGames() async {
    final saved =
        await _preferences.getStringList(_finishedGamesKey) ?? <String>[];
    final games = <GameState>[];

    for (final source in saved) {
      try {
        games.add(GameState.fromJson(source));
      } catch (_) {}
    }

    return games;
  }

  static Future<void> clearFinishedGames() async {
    await _preferences.remove(_finishedGamesKey);
  }

  static Future<void> deleteFinishedGame(GameState game) async {
    final saved =
        await _preferences.getStringList(_finishedGamesKey) ?? <String>[];

    final gameJson = game.toJson();

    final index = saved.indexOf(gameJson);

    if (index == -1) return;

    saved.removeAt(index);

    await _preferences.setStringList(_finishedGamesKey, saved);
  }
}
