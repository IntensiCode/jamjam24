import 'dart:ui';

import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/game.dart';
import 'game_controller.dart';
import 'game_model.dart';

class BlockContainerDrawer extends PositionComponent {
  late int _block_width;
  late int _block_height;

  @override
  onLoad() {
    _block_width = visual.block_size.width;
    _block_height = visual.block_size.height;
  }

  @override
  void onMount() {
    super.onMount();
    size.x = _block_width * container.width.toDouble();
    size.y = _block_height * container.height.toDouble();
  }

  @override
  render(Canvas canvas) {
    if (show_empty_container) return;

    for (final (y, row) in container.rows.indexed) {
      for (final (x, block) in row.indexed) {
        if (block == PlacedBlockId.EMPTY && !configuration.container_grid) continue;
        sprite_drawer.draw_block_at(canvas, x.toDouble(), y.toDouble(), block);
      }
    }

    if (model.state == GameState.playing_level) return;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }

  static final _paint = pixelPaint()..color = const Color(0xA0000000);
}
