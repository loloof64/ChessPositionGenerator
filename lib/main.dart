import 'dart:io';

import 'package:chess_position_generator/screens/game_page.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chess Position Generator');
    setWindowMinSize(const Size(400, 400));
    setWindowMaxSize(Size.infinite);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: FlexThemeData.light(scheme: FlexScheme.bigStone),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.bigStone),
      home: const GamePage(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
