import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/game.dart';

const overshoot = -28 * 3.0;

class VisualConfiguration {
  final side_bubbles = 20;
  final high_ball_y = 4;
  final high_ball_trigger = 8;

  final bool touch_buttons = false;

  final IntSize block_size = IntSize(28, 28);
  final IntSize container_size = IntSize(14, 25);

  final Vector2 left_colum_position = Vector2(0, overshoot);
  final Vector2 right_colum_position = Vector2(gameWidth, overshoot);
  final Vector2 container_position = Vector2(44, overshoot);
  final Vector2 scoreboard_position = Vector2(0, gameHeight + 105);
  final Vector2 touch_buttons_position = Vector2(0, gameHeight - 70);
  final Vector2 hiscore_position = Vector2(350, 30);
  final Vector2 hiscore_size = Vector2(140, 60);
}
