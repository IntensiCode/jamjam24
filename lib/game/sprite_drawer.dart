import 'dart:ui';

import 'package:dart_minilog/dart_minilog.dart';
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
  late final SpriteSheet _extras;
  late final SpriteSheet _blocks;
  late final SpriteSheet _exploding;
  late final SpriteSheet _explosion;
  late final SpriteSheet _smoke;

  @override
  onLoad() async {
    _block_width = visual.block_size.width;
    _block_height = visual.block_size.height;
    logInfo('block width: $_block_width, block height: $_block_height');
    _extras = await sheetIWH('game_extras.png', _block_width, _block_height);
    _blocks = await sheetIWH('game_blocks.png', _block_width, _block_height);
    _exploding = await sheetIWH('game_exploding.png', _block_width, _block_height);
    _explosion = await sheetIWH('game_explosion.png', _block_width, _block_height);
    _smoke = await sheetIWH('game_smoke.png', _block_width, _block_height);
    // TODO merge sprite-sheets
  }

  // void draw_block(Canvas canvas, num block_x, num block_y, PlacedBlockId id) {
  //   draw_block_at(canvas, block_x * _block_width, block_y * _block_height, id);
  // }

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
    _blocks.getSpriteById(id.index).render(canvas, position: _render_at);
  }

  void draw_extra_at(Canvas canvas, double x, double y, ExtraId id, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _extras.by_row(id.index, progress).render(canvas, position: _render_at);
  }

  void draw_explosion_at(Canvas canvas, double x, double y, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _explosion.by_progress(progress).render(canvas, position: _render_at);
  }

  void draw_exploding_at(Canvas canvas, double x, double y, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _exploding.by_progress(progress).render(canvas, position: _render_at);
  }

  void draw_smoke_at(Canvas canvas, double x, double y, double progress) {
    _render_at.setValues(x * _block_width, y * _block_height);
    _smoke.by_progress(progress).render(canvas, position: _render_at);
  }

  final _render_at = Vector2.zero();
}
