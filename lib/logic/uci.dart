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

import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';

Future<bool> checkUciPath(String absolutePath) async {
  try {
    var result = false;
    final process = await Process.start(absolutePath, <String>[]);
    process.stdin.write("isready\n");
    process.stdin.flush();
    process.stdout.transform(utf8.decoder).listen((line) {
      if (line.trim() == "readyok") result = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    return result;
  } catch (ex) {
    return false;
  }
}

class UciManager {
  late Process _process;
  final _logger = Logger();
  var _isReady = false;
  String? _bestMoveUci;
  var _isDirty = false;

  UciManager(String programPath) {
    try {
      _startProcess(programPath).then((value) => _process = value);
    } catch (ex) {
      _logger.e(ex);
    }
  }

  void setCustomPosition(String positionFen) {
    _sendCommand("position fen $positionFen");
  }

  Future<String> getBestMoveUci({int moveTimeMillis = 1000}) async {
    _isDirty = true;
    _sendCommand("go movetime $moveTimeMillis");
    while (_isDirty) {
      await Future.delayed(
        const Duration(milliseconds: 10),
      );
    }
    return Future.value(_bestMoveUci);
  }

  Future<Process> _startProcess(String path) async {
    try {
      final process = await Process.start(path, <String>[]);
      process.stdout.transform(utf8.decoder).listen((line) {
        _handleProcessLine(line);
      });
      process.stdin.write("isready\n");
      process.stdin.flush();
      return Future.value(process);
    } catch (ex) {
      return Future.error("failed to create process");
    }
  }

  void _handleProcessLine(String line) {
    final trimedLine = line.trim();
    if (trimedLine == "readyok") {
      _isReady = true;
    } else if (trimedLine.startsWith("bestmove")) {
      _bestMoveUci = trimedLine.split(" ")[1];
      _isDirty = false;
    }
  }

  void _sendCommand(String command) {
    if (!_isReady) return;
    _process.stdin.write("$command\n");
    _process.stdin.flush();
  }
}
