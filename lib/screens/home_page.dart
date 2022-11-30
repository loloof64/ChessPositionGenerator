// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chess_position_generator/screens/game_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

class SamplePositions extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return ListTile(
          onTap: () {
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
