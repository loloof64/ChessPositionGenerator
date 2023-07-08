/*
    ChessPositionGenerator : generate a chess position from your criterias.
    Copyright (C) 2022-2023  Laurent Bernabe

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chess_position_generator/logic/providers/game_provider.dart';
import 'package:chess_position_generator/logic/uci.dart';
import 'package:chess_position_generator/screens/game_page.dart';
import 'package:chess_position_generator/screens/options_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openPreferencesPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context2) => const OptionsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.mainPage_title),
            actions: [
              IconButton(
                onPressed: () => _openPreferencesPage(context),
                icon: const Icon(
                  Icons.settings,
                ),
              ),
            ],
            bottom: const TabBar(
              tabs: <Tab>[
                Tab(
                  icon: FaIcon(FontAwesomeIcons.gift),
                ),
                Tab(
                  icon: FaIcon(FontAwesomeIcons.hammer),
                ),
              ],
            )),
        body: TabBarView(
          children: [
            SamplePositions(),
            const CustomPositions(),
          ],
        ),
      ),
    );
  }
}

class SamplePositions extends ConsumerStatefulWidget {
  SamplePositions({super.key});

  final List<GameFileData> items = <GameFileData>[
    GameFileData(
      caption: 'Queen+King/King',
      path: File('/home/test'),
    ),
  ];

  @override
  ConsumerState<SamplePositions> createState() => _SamplePositionsState();
}

class _SamplePositionsState extends ConsumerState<SamplePositions> {
  late UciManager? _uciEngineHandler;
  SharedPreferences? _preferences;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) async {
      _preferences = prefs;
      var error = false;
      final enginePath = _preferences?.getString("enginePath");
      if (enginePath != null) {
        final goodEnginePath = await checkUciPath(enginePath);
        if (goodEnginePath) {
          _uciEngineHandler = UciManager(enginePath);
        } else {
          error = true;
        }
      } else {
        error = true;
      }
      if (error) {
        await Future.delayed(const Duration(milliseconds: 10));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.mainPage_noEngineSet ??
                  "UCI engine is missing : please set it in the settings.",
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return ListTile(
          onTap: () async {
            var error = false;
            final enginePath = _preferences?.getString("enginePath");
            if (enginePath != null) {
              final goodEnginePath = await checkUciPath(enginePath);
              if (!goodEnginePath) {
                error = true;
              }
            } else {
              error = true;
            }
            if (error) {
              await Future.delayed(const Duration(milliseconds: 10));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.mainPage_noEngineSet ??
                        "UCI engine is missing : please set it in the settings.",
                  ),
                ),
              );
            } else {
              final gameNotifier = ref.read(gameProvider.notifier);
              gameNotifier
                  .updateStartPosition('8/8/8/4k3/8/8/2Q5/4K3 w - - 0 12');
              gameNotifier.updateGoal(Goal.win);
              if (!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const GamePage()),
              );
            }
          },
          leading: SvgPicture.asset('assets/vectors/file.svg'),
          title: Text(widget.items[index].caption),
        );
      },
      itemCount: widget.items.length,
    );
  }
}

class CustomPositions extends StatelessWidget {
  const CustomPositions({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.mainPage_emptyListView),
    );
  }
}

class GameFileData extends Equatable {
  final String caption;
  final File path;

  const GameFileData({
    required this.caption,
    required this.path,
  });

  @override
  List<Object> get props => [caption, path];

  @override
  bool get stringify => true;
}
