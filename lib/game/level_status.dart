import '../core/common.dart';
import '../scripting/game_script.dart';
import '../util/fonts.dart';
import 'game_controller.dart';
import 'game_model.dart';

class LevelStatus extends GameScriptComponent {
  @override
  onLoad() {
    fontSelect(menuFont);
    if (model.state == GameState.game_over) {
      textXY('Game Over', xCenter, yCenter);
    }
    if (model.state == GameState.level_complete) {
      textXY('Level Complete', xCenter, yCenter);
    }
  }
}
