import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

class GameStorage {
  GameStorage._();

  static const String _currentGameKey = 'md_score.current_game.v1';
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
}
