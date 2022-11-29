import 'package:chess/chess.dart' as chess;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:simple_chess_board/models/board_arrow.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

import '../logic/utils.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final chess.Chess _gameLogic = chess.Chess();
  final BoardColor _orientation = BoardColor.white;
  final PlayerType _whitePlayerType = PlayerType.human;
  final PlayerType _blackPlayerType = PlayerType.human;
  final List<String> _movesSans = [];
  bool _gameStart = true;
  BoardArrow? _lastMoveToHighlight;

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
          _movesSans.add(moveNumberCaption);
        });
      }

      // In order to get move SAN, it must not be done on board yet !
      // So we rollback the move, then we'll make it happen again.
      _gameLogic.undo_move();
      final san = _gameLogic.move_to_san(lastPlayedMove);
      _gameLogic.make_move(lastPlayedMove);

      final fan = san.toFan(whiteMove: !whiteMove);

      setState(() {
        _movesSans.add(fan);
        _lastMoveToHighlight = BoardArrow(
          from: move.from,
          to: move.to,
          color: Colors.blueAccent,
        );
        _gameStart = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game page"),
      ),
      body: Center(
        child: SimpleChessBoard(
          fen: _gameLogic.fen,
          orientation: _orientation,
          whitePlayerType: _whitePlayerType,
          blackPlayerType: _blackPlayerType,
          onMove: _onMove,
          onPromote: _onPromote,
          lastMoveToHighlight: _lastMoveToHighlight,
        ),
      ),
    );
  }
}
