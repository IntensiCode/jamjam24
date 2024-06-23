import 'dart:ui';

import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/functions.dart';
import '../util/fonts.dart';
import 'game_controller.dart';
import 'game_model.dart';

class Scoreboard extends SpriteComponent {
  @override
  onLoad() async {
    anchor = Anchor.bottomLeft;
    position.setFrom(visual.scoreboard_position);
    sprite = Sprite(await image('skin_scoreboard.png'));
  }

  String get _level => level.level_number_starting_at_1.toString();

  String get _remaining => level.remaining_lines_to_clear.toString();

  @override
  render(Canvas canvas) {
    super.render(canvas);
    _render_text(canvas);
    if (model.state == GameState.playing_level) _render_next_tile(canvas);
  }

  void _render_text(Canvas canvas) {
    final timer_value = player.detonate_timer * 10 ~/ tps;
    final detonate_value = player.detonate_timer == 0 ? player.detonators : timer_value;

    miniFont.drawStringAligned(canvas, 10, 30, 'Level', Anchor.topLeft);
    miniFont.drawStringAligned(canvas, 130, 30, _level, Anchor.topRight);
    miniFont.drawStringAligned(canvas, 10, 60, 'Lines', Anchor.topLeft);
    miniFont.drawStringAligned(canvas, 130, 60, _remaining, Anchor.topRight);
    miniFont.drawStringAligned(canvas, 10, 90, 'Bombs', Anchor.topLeft);
    miniFont.drawStringAligned(canvas, 130, 90, '$detonate_value', Anchor.topRight);

    miniFont.drawStringAligned(canvas, 470, 30, 'Score', Anchor.topRight);
    miniFont.drawStringAligned(canvas, 470, 60, player.score.toString(), Anchor.topRight);
  }

  void _render_next_tile(Canvas canvas) {
    if (show_empty_container) return;

    final it = level.next_tile;

    final block_size = visual.block_size;
    final max_height = block_size.height * 4;
    final tile_width = it.width * block_size.width;
    final tile_height = it.height * block_size.height;
    final y = (max_height - tile_height) / 2;
    sprite_drawer.draw_tile_at(
      canvas,
      (xCenter - tile_width / 2) / visual.block_size.width,
      (10 + y) / visual.block_size.height,
      it.tile,
      it.rotation,
    );
  }
}
