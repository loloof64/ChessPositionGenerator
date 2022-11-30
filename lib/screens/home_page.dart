/*
    ChessPositionGenerator : generate a chess position from your criterias.
    Copyright (C) 2022  Laurent Bernabe

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
import 'package:chess_position_generator/screens/game_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.mainPage_title),
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

class SamplePositions extends ConsumerWidget {
  final List<GameFileData> items = <GameFileData>[
    GameFileData(
      caption: 'Queen+King/King',
      path: File('/home/test'),
    ),
  ];

  SamplePositions({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return ListTile(
          onTap: () {
            final gameNotifier = ref.read(gameProvider.notifier);
            gameNotifier
                .updateStartPosition('8/8/8/4k3/8/8/2Q5/4K3 w - - 0 12');
            gameNotifier.updateGoal(Goal.win);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const GamePage()),
            );
          },
          leading: SvgPicture.asset('assets/vectors/file.svg'),
          title: Text(items[index].caption),
        );
      },
      itemCount: items.length,
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
