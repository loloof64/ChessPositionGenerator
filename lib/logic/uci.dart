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

Future<bool> checkUciPath(String absolutePath) async {
  try {
    var result = false;
    final process = await Process.start(absolutePath, <String>[]);
    process.stdin.write("isready\n");
    process.stdin.flush();
    process.stdout.transform(utf8.decoder).listen((line) {
      print(line);
      if (line.trim() == "readyok") result = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    return result;
  } catch (ex) {
    return false;
  }
}
