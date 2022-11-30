// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Goal {
  win,
  draw,
}

@immutable
class Game {
  final String startPosition;
  final Goal goal;

  const Game({
    required this.startPosition,
    required this.goal,
  });

  Game copyWith({
    String? startPosition,
    Goal? goal,
  }) {
    return Game(
      startPosition: startPosition ?? this.startPosition,
      goal: goal ?? this.goal,
    );
  }

  Map<String, String> toMap() {
    return <String, String>{
      'startPosition': startPosition,
      'goal': goal.toString(),
    };
  }

  factory Game.fromMap(Map<String, String> map) {
    final goalStr = map['goal'];
    final goalValue =
        Goal.values.firstWhere((goal) => goal.toString() == 'Goal.$goalStr');
    return Game(
      startPosition: map['startPosition'] as String,
      goal: goalValue,
    );
  }

  String toJson() => json.encode(toMap());

  factory Game.fromJson(String source) =>
      Game.fromMap(json.decode(source) as Map<String, String>);

  @override
  String toString() => 'Game(startPosition: $startPosition, goal: $goal)';

  @override
  bool operator ==(covariant Game other) {
    if (identical(this, other)) return true;

    return other.startPosition == startPosition && other.goal == goal;
  }

  @override
  int get hashCode => startPosition.hashCode ^ goal.hashCode;
}

const _emptyPosition = '8/8/8/8/8/8/8/8 w - - 0 1';

class GameNotifier extends StateNotifier<Game> {
  GameNotifier()
      : super(
          const Game(
            startPosition: _emptyPosition,
            goal: Goal.win,
          ),
        );

  void updateStartPosition(String newPosition) {
    state = state.copyWith(startPosition: newPosition);
  }

  void updateGoal(Goal newGoal) {
    state = state.copyWith(goal: newGoal);
  }
}

final gameProvider =
    StateNotifierProvider<GameNotifier, Game>((ref) => GameNotifier());
