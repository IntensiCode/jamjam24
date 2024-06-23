import 'package:flame/components.dart';

import 'input/game_keys.dart';
import 'input/shortcuts.dart';
import 'scripting/game_script.dart';

class OptionsScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, HasGameKeys {
  @override
  onLoad() async {}
}
