// ignore_for_file: non_constant_identifier_names

import 'package:flame/components.dart';

import 'input/game_keys.dart';
import 'input/shortcuts.dart';
import 'scripting/game_script.dart';

class GameScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, GameKeys {
  @override
  onLoad() async {}
}
