import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import 'components/falling_text.dart';
import 'components/soft_keys.dart';
import 'core/common.dart';
import 'core/screens.dart';
import 'input/game_keys.dart';
import 'input/shortcuts.dart';
import 'scripting/game_script.dart';
import 'util/effects.dart';
import 'util/extensions.dart';
import 'util/fonts.dart';

class TitleScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, HasGameKeys {
  @override
  onLoad() async {
    final title = await spriteXY('title.png', xCenter, yCenter / 2);
    title.add(JumpyEffect());

    final credits = await game.assets.readFile('data/credits.txt');
    add(FallingText(
      menuFont,
      credits,
      position: Vector2(xCenter, yCenter),
      size: Vector2(gameWidth, gameHeight / 2),
      anchor: Anchor.topCenter,
    ));

    await softkeys('Menu', 'Start', (it) {
      logInfo(it);
      if (it == SoftKey.left) pushScreen(Screen.main_menu);
      if (it == SoftKey.right) pushScreen(Screen.game);
    });

    fadeInDeep();
  }
}
