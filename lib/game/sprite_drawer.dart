import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../core/functions.dart';
import '../core/game.dart';
import '../util/extensions.dart';
import 'placed_tile.dart';
import 'tile.dart';
import 'visual_configuration.dart';

class SpriteDrawer extends Component {
  SpriteDrawer(this.visual);

  final VisualConfiguration visual;

  late int _block_width;
  late int _block_height;
  late final SpriteSheet _sheet;

  @override
  onLoad() async {
    _block_width = visual.block_size.width;
    _block_height = visual.block_size.height;
    _sheet = await sheetIWH('game_sheet.png', _block_width, _block_height);
  }

  void draw_tile(Canvas canvas, PlacedTile tile, {bool ghost = false}) {
    final x = tile.pos_x.toDouble();
    final y = tile.pos_y.toDouble();
    draw_tile_at(canvas, x, y, tile.tile, tile.rotation, ghost: ghost);
  }

  void draw_tile_at(Canvas canvas, double x, double y, Tile tile, TileRotation rotation, {bool ghost = false}) {
    final width = tile.width(rotation);
    final height = tile.height(rotation);
    for (var j = 0; j < height; j++) {
      for (var i = 0; i < width; i++) {
        if (tile.is_set(i, j, rotation)) {
          final id = ghost ? PlacedBlockId.GHOST : tile.id;
          draw_block_at(canvas, x + i, y + j, id);
        }
      }
    }
  }

  void draw_block_at(Canvas canvas, double x, double y, PlacedBlockId id) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _sheet.getSpriteById(id.index).render(canvas, position: _render_at);
  }

  void draw_extra_at(Canvas canvas, double x, double y, ExtraId id, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _sheet.by_row(3 + id.index, progress).render(canvas, position: _render_at);
  }

  void draw_explosion_at(Canvas canvas, double x, double y, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _sheet.by_row(11, progress).render(canvas, position: _render_at);
  }

  void draw_exploding_at(Canvas canvas, double x, double y, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _sheet.by_row(2, progress).render(canvas, position: _render_at);
  }

  void draw_smoke_at(Canvas canvas, double x, double y, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _sheet.by_row(12, progress).render(canvas, position: _render_at);
  }

  final _render_at = Vector2.zero();
}
