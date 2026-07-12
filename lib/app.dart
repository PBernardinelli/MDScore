import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_game_screen.dart';
import 'screens/settings_screen.dart';

class MDScoreApp extends StatelessWidget {
  const MDScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MD Score',
      theme: AppTheme.dark,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        NewGameScreen.routeName: (_) => const NewGameScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
