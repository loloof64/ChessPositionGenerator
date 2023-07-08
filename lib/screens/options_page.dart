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

import 'package:chess_position_generator/logic/uci.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  TextEditingController? _enginePath;
  SharedPreferences? _preferences;

  @override
  void initState() {
    _enginePath = TextEditingController();
    SharedPreferences.getInstance().then((value) {
      _preferences = value;
      _loadSettings();
    });
    super.initState();
  }

  @override
  void dispose() {
    _enginePath?.dispose();
    super.dispose();
  }

  void _loadSettings() async {
    final registeredEnginePath = _preferences?.getString('enginePath');
    if (registeredEnginePath != null) {
      setState(() {
        _enginePath?.text = registeredEnginePath;
      });
    }
  }

  void _selectEnginePath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final isValid = await checkUciPath(result.files.single.path!);
      if (isValid) {
        setState(() {
          _enginePath?.text = result.files.single.path!;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.optionsPage_wrongUciProgram ??
                  'Selected program is not a valid UCI program, or failed to launch.',
            ),
          ),
        );
      }
    }
  }

  void _eraseEnginePath() async {
    setState(() {
      _enginePath?.text = "";
    });
  }

  void _validate() {
    if (_enginePath?.text != null) {
      _preferences?.setString(
        'enginePath',
        _enginePath!.text,
      );
    }

    Navigator.of(context).pop();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.optionsPage_title,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _enginePath,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          ?.optionsPage_enginePathHint,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectEnginePath,
                  child: Text(
                    AppLocalizations.of(context)?.buttons_select ?? "Select",
                  ),
                ),
                ElevatedButton(
                  onPressed: _eraseEnginePath,
                  child: Text(
                    AppLocalizations.of(context)?.buttons_erase ?? "Erase",
                  ),
                )
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 6.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _cancel,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.redAccent,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.buttons_cancel ?? 'Cancel',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 30.0,
                  ),
                  ElevatedButton(
                    onPressed: _validate,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.greenAccent,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.buttons_ok ?? 'Ok',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
