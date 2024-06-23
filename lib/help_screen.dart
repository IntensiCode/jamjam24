import 'package:flame/components.dart';

import 'components/scrolled_text.dart';
import 'components/soft_keys.dart';
import 'core/common.dart';
import 'core/screens.dart';
import 'scripting/game_script.dart';
import 'util/fonts.dart';

class HelpScreen extends GameScriptComponent {
  @override
  void onLoad() async {
    fontSelect(menuFont, scale: 1);
    textXY('Help', xCenter, lineHeight * 2, scale: 1.5);

    final help = await game.assets.readFile('data/help.txt');
    add(ScrolledText(
      text: help,
      font: smallFont,
      size: Vector2(gameWidth, gameHeight - lineHeight * 8),
      position: Vector2(0, lineHeight * 4),
    ));

    softkeys('Back', null, (_) => popScreen());
  }
}
