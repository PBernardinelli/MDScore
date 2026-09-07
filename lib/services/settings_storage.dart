import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  SettingsStorage._();

  static const String _confirmNewGameKey =
      'md_score.settings.confirm_new_game.v1';

  static const String _soundEnabledKey = 'md_score.settings.sound_enabled.v1';

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static const String _regularPlayersKey =
      'md_score.settings.regular_players.v1';

  static Future<bool> loadConfirmNewGame() async {
    return await _preferences.getBool(_confirmNewGameKey) ?? true;
  }

  static Future<void> saveConfirmNewGame(bool value) async {
    await _preferences.setBool(_confirmNewGameKey, value);
  }

  static Future<bool> loadSoundEnabled() async {
    return await _preferences.getBool(_soundEnabledKey) ?? true;
  }

  static Future<void> saveSoundEnabled(bool value) async {
    await _preferences.setBool(_soundEnabledKey, value);
  }

  static Future<List<String>> loadRegularPlayers() async {
    return await _preferences.getStringList(_regularPlayersKey) ?? <String>[];
  }

  static Future<void> saveRegularPlayers(List<String> players) async {
    await _preferences.setStringList(_regularPlayersKey, players);
  }

  static const String _textSizeKey = 'md_score.settings.text_size.v1';

  static Future<String> loadTextSize() async {
    return await _preferences.getString(_textSizeKey) ?? 'normal';
  }

  static Future<void> saveTextSize(String value) async {
    await _preferences.setString(_textSizeKey, value);
  }
}
