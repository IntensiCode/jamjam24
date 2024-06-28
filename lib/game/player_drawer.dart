import 'dart:ui';

import 'package:flame/components.dart';

import 'game_controller.dart';
import 'game_model.dart';
import 'player.dart';

class PlayerDrawer extends Component {
  @override
  void render(Canvas canvas) {
    if (show_empty_container) return;
    if (player.state != PlayerState.playing) return;
    if (model.state != GameState.playing_level) return;

    final it = player.active_tile;
    if (!it.is_still_valid) return;

    if (it.draw_drop_guide) {
      sprite_drawer.draw_tile(canvas, it.drop_guide!, ghost: true);
    }
    sprite_drawer.draw_tile(canvas, it);
  }
}
