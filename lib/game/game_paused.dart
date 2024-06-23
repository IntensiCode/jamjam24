import '../core/common.dart';
import '../scripting/game_script.dart';
import '../util/fonts.dart';

class GamePaused extends GameScriptComponent {
  @override
  onLoad() {
    fontSelect(menuFont);
    textXY('Game Paused', xCenter, yCenter);
  }
}
