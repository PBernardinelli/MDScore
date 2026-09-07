import 'package:flutter/material.dart';

import 'core/app_theme.dart';

import 'services/settings_storage.dart';

import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_game_screen.dart';
import 'screens/settings_screen.dart';

class MDScoreApp extends StatefulWidget {
  const MDScoreApp({super.key});

  @override
  State<MDScoreApp> createState() => _MDScoreAppState();
}

class _MDScoreAppState extends State<MDScoreApp> {
  String _textSize = 'normal';

  @override
  void initState() {
    super.initState();
    _loadTextSize();
  }

  Future<void> _refreshTextSize() async {
    final textSize = await SettingsStorage.loadTextSize();

    if (!mounted) return;

    setState(() {
      _textSize = textSize;
    });
  }

  Future<void> _loadTextSize() async {
    final textSize = await SettingsStorage.loadTextSize();

    if (!mounted) return;

    setState(() {
      _textSize = textSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MD Score',
      theme: AppTheme.dark,
      builder: (context, child) {
        final scale = _textSize == 'large' ? 1.20 : 1.0;

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        NewGameScreen.routeName: (_) => const NewGameScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        SettingsScreen.routeName: (_) =>
            SettingsScreen(onTextSizeChanged: _refreshTextSize),
      },
    );
  }
}
