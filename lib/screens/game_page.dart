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

import 'package:chess/chess.dart' as chess;
import 'package:chess_position_generator/logic/providers/game_provider.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chess_board/models/board_arrow.dart';
import 'package:simple_chess_board/simple_chess_board.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';

import 'package:chess_position_generator/components/history/history.dart';

import '../logic/utils.dart';

const emptyBoardFen = '8/8/8/8/8/8/8/8 w - - 0 1';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  chess.Chess _gameLogic = chess.Chess.fromFEN(emptyBoardFen);
  BoardColor _orientation = BoardColor.white;
  final PlayerType _whitePlayerType = PlayerType.human;
  final PlayerType _blackPlayerType = PlayerType.human;
  bool _gameStart = true;
  bool _gameInProgress = false;
  BoardArrow? _lastMoveToHighlight;
  List<HistoryNode> _historyhistoryNodesDescriptions = [];
  final ScrollController _historyScrollController = ScrollController();
  int? _selectedHistoryItemIndex = -1;

  void _onMove({required ShortMove move}) {
    final moveHasBeenMade = _gameLogic.move({
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion.map((t) => t.name).toNullable(),
    });
    if (moveHasBeenMade) {
      final whiteMove = _gameLogic.turn == chess.Color.WHITE;
      final lastPlayedMove = _gameLogic.history.last.move;

      /*
      We need to know if it was white move before the move which
      we want to add history node(s).
      */
      if (!whiteMove && !_gameStart) {
        final moveNumberCaption = "${_gameLogic.fen.split(' ')[5]}.";
        setState(() {
          _historyhistoryNodesDescriptions
              .add(HistoryNode(caption: moveNumberCaption));
        });
      }

      // In order to get move SAN, it must not be done on board yet !
      // So we rollback the move, then we'll make it happen again.
      _gameLogic.undo_move();
      final san = _gameLogic.move_to_san(lastPlayedMove);
      _gameLogic.make_move(lastPlayedMove);

      final fan = san.toFan(whiteMove: !whiteMove);

      setState(() {
        _historyhistoryNodesDescriptions.add(
          HistoryNode(
            caption: fan,
            fen: _gameLogic.fen,
            move: Move(
              from: Cell.fromString(move.from),
              to: Cell.fromString(move.to),
            ),
          ),
        );
        _lastMoveToHighlight = BoardArrow(
          from: move.from,
          to: move.to,
          color: Colors.blueAccent,
        );
        _gameStart = false;
      });

      _handleGameEndedIfNeeded();
    }
  }

  void _purposeStartNewGame() {
    final bool gameStarted = _gameLogic.fen != emptyBoardFen;
    if (gameStarted) {
      final confirmationDialog = AlertDialog(
        title: Text(AppLocalizations.of(context)!.gamePage_newGame_title),
        content: Text(
          AppLocalizations.of(context)!.gamePage_newGame_message,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.buttons_cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _doStartNewGame();
            },
            child: Text(
              AppLocalizations.of(context)!.buttons_ok,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      );
      showDialog(
          context: context,
          builder: (ctx) {
            return confirmationDialog;
          });
    } else {
      _doStartNewGame();
    }
  }

  void _doStartNewGame() {
    final startPosition = ref.read(gameProvider).startPosition;
    setState(() {
      _gameLogic = chess.Chess.fromFEN(startPosition);
    });
    final moveNumberCaption = "${_gameLogic.fen.split(' ')[5]}.";
    setState(() {
      _gameStart = true;
      _lastMoveToHighlight = null;
      _historyhistoryNodesDescriptions = [];
      _historyhistoryNodesDescriptions
          .add(HistoryNode(caption: moveNumberCaption));
      _selectedHistoryItemIndex = -1;
      _gameInProgress = true;
    });
  }

  void _toggleBoardOrientation() {
    setState(() {
      _orientation = _orientation == BoardColor.white
          ? BoardColor.black
          : BoardColor.white;
    });
  }

  void _handleGameEndedIfNeeded() {
    String? snackMessage;
    if (_gameLogic.in_checkmate) {
      final whiteTurnBeforeMove = _gameLogic.turn == chess.Color.BLACK;
      snackMessage = whiteTurnBeforeMove
          ? AppLocalizations.of(context)!.gamePage_checkmate_white
          : AppLocalizations.of(context)!.gamePage_checkmate_black;
    } else if (_gameLogic.in_stalemate) {
      snackMessage = AppLocalizations.of(context)!.gamePage_stalemate;
    } else if (_gameLogic.in_threefold_repetition) {
      snackMessage = AppLocalizations.of(context)!.gamePage_threeFoldRepetition;
    } else if (_gameLogic.insufficient_material) {
      snackMessage = AppLocalizations.of(context)!.gamePage_missingMaterial;
    } else if (_gameLogic.in_draw) {
      snackMessage = AppLocalizations.of(context)!.gamePage_fiftyMovesRule;
    }

    if (snackMessage != null) {
      setState(() {
        _gameInProgress = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackMessage),
        ),
      );
      _selectLastHistoryNode();
    }
  }

  Future<PieceType?> _onPromote() {
    final whiteTurn = _gameLogic.fen.split(' ')[1] == 'w';
    const piecesSize = 60.0;
    return showDialog<PieceType>(
        context: context,
        builder: (ctx2) {
          return AlertDialog(
            alignment: Alignment.center,
            content: FittedBox(
                child: Row(
              children: [
                InkWell(
                  child: whiteTurn
                      ? WhiteQueen(
                          size: piecesSize,
                        )
                      : BlackQueen(
                          size: piecesSize,
                        ),
                  onTap: () {
                    Navigator.of(context).pop(PieceType.queen);
                  },
                ),
                InkWell(
                  child: whiteTurn
                      ? WhiteRook(
                          size: piecesSize,
                        )
                      : BlackRook(
                          size: piecesSize,
                        ),
                  onTap: () {
                    Navigator.of(context).pop(PieceType.rook);
                  },
                ),
                InkWell(
                  child: whiteTurn
                      ? WhiteBishop(
                          size: piecesSize,
                        )
                      : BlackBishop(
                          size: piecesSize,
                        ),
                  onTap: () {
                    Navigator.of(context).pop(PieceType.bishop);
                  },
                ),
                InkWell(
                  child: whiteTurn
                      ? WhiteKnight(
                          size: piecesSize,
                        )
                      : BlackKnight(
                          size: piecesSize,
                        ),
                  onTap: () {
                    Navigator.of(context).pop(PieceType.knight);
                  },
                ),
              ],
            )),
          );
        });
  }

  void _selectFirstGamePosition() {
    if (_gameInProgress) return;
    final startPosition = ref.read(gameProvider).startPosition;
    setState(() {
      _selectedHistoryItemIndex = null;
      _lastMoveToHighlight = null;
      _gameLogic = chess.Chess.fromFEN(startPosition);
    });
  }

  void _selectPreviousHistoryNode() {
    if (_gameInProgress) return;
    if (_selectedHistoryItemIndex == null) return;
    /*
    We test against value 2 because
    value 0 is for the first move number
    and value 1 is for the first move san
    */
    if (_selectedHistoryItemIndex! < 2) {
      // selecting first game position
      final startPosition = ref.read(gameProvider).startPosition;
      setState(() {
        _selectedHistoryItemIndex = null;
        _lastMoveToHighlight = null;
        _gameLogic = chess.Chess.fromFEN(startPosition);
      });
      return;
    }
    final previousNodeData = _historyhistoryNodesDescriptions
        .mapIndexed((index, element) => Tuple2(index, element))
        .where((element) => element.item2.fen != null)
        .takeWhile((element) => element.item1 != _selectedHistoryItemIndex)
        .lastOrNull;
    if (previousNodeData == null) return;

    final moveData = previousNodeData.item2.move!;

    setState(() {
      _selectedHistoryItemIndex = previousNodeData.item1;
      _gameLogic = chess.Chess.fromFEN(previousNodeData.item2.fen!);
      _lastMoveToHighlight = BoardArrow(
        from: moveData.from.getUciString(),
        to: moveData.to.getUciString(),
        color: Colors.blueAccent,
      );
    });
  }

  void _selectNextHistoryNode() {
    if (_gameInProgress) return;
    if (_selectedHistoryItemIndex == null) {
      // Move number and first move san, at least
      if (_historyhistoryNodesDescriptions.length >= 2) {
        setState(() {
          // First move san
          _selectedHistoryItemIndex = 1;
        });
      }
      return;
    }
    final nextNodeData = _historyhistoryNodesDescriptions
        .mapIndexed((index, element) => Tuple2(index, element))
        .where((element) => element.item2.fen != null)
        .skipWhile((element) => element.item1 != _selectedHistoryItemIndex)
        .skip(1)
        .firstOrNull;
    if (nextNodeData == null) return;

    final moveData = nextNodeData.item2.move!;
    setState(() {
      _selectedHistoryItemIndex = nextNodeData.item1;
      _gameLogic = chess.Chess.fromFEN(nextNodeData.item2.fen!);
      _lastMoveToHighlight = BoardArrow(
        from: moveData.from.getUciString(),
        to: moveData.to.getUciString(),
        color: Colors.blueAccent,
      );
    });
  }

  void _selectLastHistoryNode() {
    if (_gameInProgress) return;
    final lastNodeData = _historyhistoryNodesDescriptions
        .mapIndexed((index, element) => Tuple2(index, element))
        .where((element) => element.item2.fen != null)
        .lastOrNull;
    if (lastNodeData == null) return;

    final moveData = lastNodeData.item2.move!;
    setState(() {
      _selectedHistoryItemIndex = lastNodeData.item1;
      _gameLogic = chess.Chess.fromFEN(lastNodeData.item2.fen!);
      _lastMoveToHighlight = BoardArrow(
        from: moveData.from.getUciString(),
        to: moveData.to.getUciString(),
        color: Colors.blueAccent,
      );
    });
  }

  void _onHistoryMoveRequest(
      {required Move historyMove, required int? selectedHistoryNodeIndex}) {}

  void _onStopRequested() {
    final noGameRunning =
        (_gameLogic.fen == emptyBoardFen) || (_gameInProgress == false);
    if (noGameRunning) return;

    final confirmDialog = AlertDialog(
      title: Text(AppLocalizations.of(context)!.gamePage_stopGame_title),
      content: Text(AppLocalizations.of(context)!.gamePage_stopGame_message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.buttons_cancel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _doStopGame();
          },
          child: Text(
            AppLocalizations.of(context)!.buttons_ok,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (ctx) {
          return confirmDialog;
        });
  }

  void _doStopGame() {
    final snackBar = SnackBar(
      content: Text(AppLocalizations.of(context)!.gamePage_gameStopped),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      _gameInProgress = false;
    });
    _selectLastHistoryNode();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).size.width < MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.gamePage_title,
        ),
        actions: [
          IconButton(
            onPressed: _purposeStartNewGame,
            icon: const Icon(
              Icons.start,
            ),
          ),
          IconButton(
            onPressed: _toggleBoardOrientation,
            icon: const Icon(
              Icons.swap_vert,
            ),
          ),
          IconButton(
            onPressed: _onStopRequested,
            icon: const Icon(
              Icons.back_hand,
            ),
          )
        ],
      ),
      body: Center(
        child: isPortrait
            ? PortraitWidget(
                gameInProgress: _gameInProgress,
                positionFen: _gameLogic.fen,
                boardOrientation: _orientation,
                whitePlayerType: _whitePlayerType,
                blackPlayerType: _blackPlayerType,
                lastMoveToHighlight: _lastMoveToHighlight,
                onPromote: _onPromote,
                onMove: _onMove,
                historySelectedNodeIndex: _selectedHistoryItemIndex,
                historyNodesDescriptions: _historyhistoryNodesDescriptions,
                historyScrollController: _historyScrollController,
                requestGotoFirst: _selectFirstGamePosition,
                requestGotoPrevious: _selectPreviousHistoryNode,
                requestGotoNext: _selectNextHistoryNode,
                requestGotoLast: _selectLastHistoryNode,
                requestHistoryMove: _onHistoryMoveRequest,
              )
            : LandscapeWidget(
                gameInProgress: _gameInProgress,
                positionFen: _gameLogic.fen,
                boardOrientation: _orientation,
                whitePlayerType: _whitePlayerType,
                blackPlayerType: _blackPlayerType,
                lastMoveToHighlight: _lastMoveToHighlight,
                onPromote: _onPromote,
                onMove: _onMove,
                historySelectedNodeIndex: _selectedHistoryItemIndex,
                historyNodesDescriptions: _historyhistoryNodesDescriptions,
                historyScrollController: _historyScrollController,
                requestGotoFirst: _selectFirstGamePosition,
                requestGotoPrevious: _selectPreviousHistoryNode,
                requestGotoNext: _selectNextHistoryNode,
                requestGotoLast: _selectLastHistoryNode,
                requestHistoryMove: _onHistoryMoveRequest,
              ),
      ),
    );
  }
}

class PortraitWidget extends StatelessWidget {
  final bool gameInProgress;
  final String positionFen;
  final BoardColor boardOrientation;
  final PlayerType whitePlayerType;
  final PlayerType blackPlayerType;
  final BoardArrow? lastMoveToHighlight;
  final void Function({required ShortMove move}) onMove;
  final Future<PieceType?> Function() onPromote;

  final int? historySelectedNodeIndex;
  final List<HistoryNode> historyNodesDescriptions;
  final ScrollController historyScrollController;
  final void Function() requestGotoFirst;
  final void Function() requestGotoPrevious;
  final void Function() requestGotoNext;
  final void Function() requestGotoLast;
  final void Function(
      {required Move historyMove,
      required int? selectedHistoryNodeIndex}) requestHistoryMove;

  const PortraitWidget({
    super.key,
    required this.gameInProgress,
    required this.positionFen,
    required this.boardOrientation,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.lastMoveToHighlight,
    required this.onPromote,
    required this.onMove,
    required this.historySelectedNodeIndex,
    required this.historyNodesDescriptions,
    required this.historyScrollController,
    required this.requestGotoFirst,
    required this.requestGotoPrevious,
    required this.requestGotoNext,
    required this.requestGotoLast,
    required this.requestHistoryMove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: SimpleChessBoard(
            fen: positionFen,
            orientation: boardOrientation,
            whitePlayerType:
                gameInProgress ? whitePlayerType : PlayerType.computer,
            blackPlayerType:
                gameInProgress ? blackPlayerType : PlayerType.computer,
            onMove: onMove,
            onPromote: onPromote,
            lastMoveToHighlight: lastMoveToHighlight,
          ),
        ),
        const Divider(height: 20.0),
        Expanded(
          flex: 1,
          child: LayoutBuilder(builder: (ctx2, constraints2) {
            return ChessHistory(
              fontSize: constraints2.biggest.height * 0.1,
              selectedNodeIndex: historySelectedNodeIndex,
              nodesDescriptions: historyNodesDescriptions,
              scrollController: historyScrollController,
              requestGotoFirst: requestGotoFirst,
              requestGotoPrevious: requestGotoPrevious,
              requestGotoNext: requestGotoNext,
              requestGotoLast: requestGotoLast,
              onHistoryMoveRequested: requestHistoryMove,
            );
          }),
        ),
      ],
    );
  }
}

class LandscapeWidget extends StatelessWidget {
  final bool gameInProgress;
  final String positionFen;
  final BoardColor boardOrientation;
  final PlayerType whitePlayerType;
  final PlayerType blackPlayerType;
  final BoardArrow? lastMoveToHighlight;
  final void Function({required ShortMove move}) onMove;
  final Future<PieceType?> Function() onPromote;

  final int? historySelectedNodeIndex;
  final List<HistoryNode> historyNodesDescriptions;
  final ScrollController historyScrollController;
  final void Function() requestGotoFirst;
  final void Function() requestGotoPrevious;
  final void Function() requestGotoNext;
  final void Function() requestGotoLast;
  final void Function(
      {required Move historyMove,
      required int? selectedHistoryNodeIndex}) requestHistoryMove;

  const LandscapeWidget({
    super.key,
    required this.gameInProgress,
    required this.positionFen,
    required this.boardOrientation,
    required this.whitePlayerType,
    required this.blackPlayerType,
    required this.lastMoveToHighlight,
    required this.onPromote,
    required this.onMove,
    required this.historySelectedNodeIndex,
    required this.historyNodesDescriptions,
    required this.historyScrollController,
    required this.requestGotoFirst,
    required this.requestGotoPrevious,
    required this.requestGotoNext,
    required this.requestGotoLast,
    required this.requestHistoryMove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SimpleChessBoard(
          fen: positionFen,
          orientation: boardOrientation,
          whitePlayerType:
              gameInProgress ? whitePlayerType : PlayerType.computer,
          blackPlayerType:
              gameInProgress ? blackPlayerType : PlayerType.computer,
          onMove: onMove,
          onPromote: onPromote,
          lastMoveToHighlight: lastMoveToHighlight,
        ),
        const Divider(height: 20.0),
        Expanded(
          child: LayoutBuilder(builder: (ctx2, constraints2) {
            return ChessHistory(
              fontSize: constraints2.biggest.height * 0.07,
              selectedNodeIndex: historySelectedNodeIndex,
              nodesDescriptions: historyNodesDescriptions,
              scrollController: historyScrollController,
              requestGotoFirst: requestGotoFirst,
              requestGotoPrevious: requestGotoPrevious,
              requestGotoNext: requestGotoNext,
              requestGotoLast: requestGotoLast,
              onHistoryMoveRequested: requestHistoryMove,
            );
          }),
        ),
      ],
    );
  }
}
