import 'dart:ui';

import '../core/common.dart';
import 'block_container.dart';
import 'extras.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'game_particles.dart';
import 'placed_tile.dart';

class DroppedTiles extends GameParticles<_DroppedTile> {
  DroppedTiles() : super(_DroppedTile.new);

  void drop(PlacedTile tile, int drop_interval) => require_particle()
    ..init(tile, drop_interval)
    ..activate();

  @override
  onMount() {
    _DroppedTile.extras = extras;
    _DroppedTile.container = container;
  }

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      sprite_drawer.draw_tile(canvas, it.tile);
    }
  }
}

class _DroppedTile with HasGameData, GameParticle, ManagedGameParticle {
  static late Extras extras;
  static late BlockContainer container;

  @override
  bool get loop => true;

  final tile = PlacedTile();

  void init(PlacedTile it, int step_delay_in_ticks) {
    tile.init_(it);
    tick_duration = step_delay_in_ticks;
  }

  // GameParticle

  @override
  void update_while_active() {
    for (final it in extras.active_particles) {
      _check_if_hit(it);
      if (!tile.is_still_valid) active = false;
      if (!active) return;
    }

    if (!tile.is_still_valid) active = false;
    if (!active) return;

    if (tick_counter == tick_duration) _move_tile();
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    tile.load_state(data);
  }

  @override
  GameData save_state(GameData data) => super.save_state(data..['tile'] = tile.save_state({}));

  // Implementation

  void _check_if_hit(Extra aExtra) {
    final xOffset = tile.pos_x;
    final yOffset = tile.pos_y;

    if (!tile.is_basic_tile) return;

    final int height = tile.height;
    for (int y = 0; y < height; y++) {
      final int width = tile.width;
      for (int x = 0; x < width; x++) {
        if (!tile.is_set(x, y)) continue;

        final xPos = xOffset + x;
        final yPos = yOffset + y;
        final xExtra = aExtra.x - 0.5;
        final yExtra = aExtra.y - 0.5;
        final leftOk = xPos < (xExtra + 1);
        final rightOk = (xPos + 1) > xExtra;
        final topOk = yPos < (yExtra + 1);
        final bottomOk = (yPos + 1) > yExtra;

        if (leftOk && rightOk && topOk && bottomOk) {
          aExtra.apply(tile, tps ~/ 2);
          tile.reset();
          return;
        }
      }
    }
  }

  void _move_tile() {
    tile.position.y++;
    tick_counter = 0;

    if (container.can_be_placed(tile)) return;

    tile.position.y--;
    container.place_tile(tile);

    active = false;
  }
}
