import '../core/common.dart';
import '../scripting/game_script.dart';
import '../util/fonts.dart';

class ConfirmExit extends GameScriptComponent {
  @override
  onLoad() {
    fontSelect(menuFont);
    textXY('Back to menu?', xCenter, yCenter);
  }
}
