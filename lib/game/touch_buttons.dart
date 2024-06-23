import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/functions.dart';
import 'game_controller.dart';

class TouchButtons extends SpriteComponent {
  @override
  onLoad() async {
    sprite = Sprite(await image('skin_touch.png'));
    scale.setAll(gameWidth / sprite!.srcSize.x);
    anchor = Anchor.bottomLeft;
    position.setFrom(visual.touch_buttons_position);
  }
}
