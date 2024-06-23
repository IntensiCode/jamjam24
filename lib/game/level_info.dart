import '../core/common.dart';
import '../scripting/game_script.dart';
import '../util/fonts.dart';
import 'game_model.dart';

class LevelInfo extends GameScriptComponent {
  int get _level => level.level_number_starting_at_1;

  int get _remaining => level.remaining_lines_to_clear;

  @override
  onLoad() {
    fontSelect(menuFont);
    textXY('Level $_level', xCenter, yCenter - lineHeight * 1.5);
    textXY('Clear $_remaining Lines', xCenter, yCenter + lineHeight * 1.5);
  }
}
