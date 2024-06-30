import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:jamjam24/game/game_controller.dart';

import '../core/common.dart';
import '../scripting/game_script.dart';
import '../util/effects.dart';
import '../util/fonts.dart';
import 'game_model.dart';

class LevelInfo extends GameScriptComponent with HasVisibility {
  int get _level => level.level_number_starting_at_1;

  int get _remaining => level.remaining_lines_to_clear;

  @override
  onLoad() {
    fontSelect(menuFont);
    textXY('Level $_level', xCenter, yCenter - lineHeight * 1.5);
    textXY('Clear $_remaining Lines', xCenter, yCenter + lineHeight * 1.5);
    if (model.state != GameState.start_game) {
      add(RemoveEffect(delay: 1.9));
      add(BlinkEffect(on: 0.3, off: 0.1));
    }
  }
}
