import 'package:dart_minilog/dart_minilog.dart';

import 'components/soft_keys.dart';
import 'core/common.dart';
import 'core/screens.dart';
import 'game/game_model.dart';
import 'game/hiscore.dart';
import 'input/shortcuts.dart';
import 'scripting/game_script.dart';
import 'util/fonts.dart';

class EnterHiscoreScreen extends GameScriptComponent with HasAutoDisposeShortcuts {
  @override
  onLoad() {
    logInfo('ENTERHISCORESCREEN');

    fontSelect(textFont);
    textXY('You made it into the', xCenter, lineHeight * 2);
    fontSelect(menuFont);
    textXY('HISCORE', xCenter, lineHeight * 3);

    fontSelect(textFont);
    textXY('Score', xCenter, lineHeight * 5);
    fontSelect(menuFont);
    textXY('${player.score}', xCenter, lineHeight * 6);

    fontSelect(textFont);
    textXY('Level', xCenter, lineHeight * 8);
    fontSelect(menuFont);
    textXY('${level.level_number_starting_at_1}', xCenter, lineHeight * 9);

    fontSelect(textFont);
    textXY('Enter your name:', xCenter, lineHeight * 12);

    fontSelect(menuFont);
    var input = textXY('_', xCenter, lineHeight * 13);

    softkeys('Cancel', 'Ok', (it) {
      if (it == SoftKey.left) {
        popScreen(); // TODO confirm
      } else if (it == SoftKey.right && name.isNotEmpty) {
        shortcuts.snoop = (_) {};
        hiscore.insert(player.score, level.level_number_starting_at_1, name);
        showScreen(Screen.hiscore);
      }
    });

    shortcuts.snoop = (it) {
      if (it.length == 1) {
        name += it;
      } else if (it == '<Space>' && name.isNotEmpty) {
        name += ' ';
      } else if (it == '<Backspace>' && name.isNotEmpty) {
        name = name.substring(0, name.length - 1);
      } else if (it == '<Enter>' && name.isNotEmpty) {
        shortcuts.snoop = (_) {};
        hiscore.insert(player.score, level.level_number_starting_at_1, name);
        showScreen(Screen.hiscore);
      }
      if (name.length > 10) name = name.substring(0, 10);

      input.removeFromParent();

      fontSelect(menuFont);
      input = textXY('${name}_', xCenter, lineHeight * 13);
    };
  }

  String name = '';
}
