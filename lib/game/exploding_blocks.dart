import 'dart:ui';

import '../core/common.dart';
import '../core/game.dart';
import 'block_container.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'game_particles.dart';

class ExplodingBlocks extends GameParticles<_ExplodingBlock> {
  ExplodingBlocks() : super(_ExplodingBlock.new);

  late final BlockContainer _container;
  late final int _width;

  @override
  void onMount() {
    _container = container;
    _width = _container.width;
  }

  void spawn_at(int aX, int aY, int width) {
    const baseTicks = tps * 3 / 4;
    const tickDuration = baseTicks ~/ 2;
    final tickIndex = (((aX & 1) == 1) ? aX : (width - 1 - aX));
    final tickDelay = tickIndex * baseTicks ~/ width ~/ 2;
    require_particle()
      ..init_position(aX.toDouble(), aY.toDouble())
      ..init_timing(tickDelay, tickDuration)
      ..activate();
  }

  void spawn_full_row(int row, int tickOffset, int tickDuration) {
    for (int x = 0; x < _width; x++) {
      final tile = _container.rows[row][x];
      if (tile == PlacedBlockId.EMPTY) continue;

      final int tickIndex = (((x & 1) == 1) ? x : (_width - 1 - x));
      final int tickDelay = tickIndex * tps ~/ _width ~/ 2;

      require_particle()
        ..init_position(x.toDouble(), row.toDouble())
        ..init_timing(tickOffset + tickDelay, tickDuration)
        ..activate();

      _container.rows[row][x] = PlacedBlockId.EXPLODED;
    }
  }

  void on_line_inserted() => active_particles.forEach((it) => it.move_up());

  void on_line_removed(int aLineIndex) {
    for (final it in active_particles) {
      if (it.y < aLineIndex) it.move_down();
      if (it.y == aLineIndex) it.active = false;
    }
  }

  @override
  onLoad() async => _ExplodingBlock.container = container;

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      sprite_drawer.draw_exploding_at(canvas, it.x, it.y, it.progress);
    }
  }
}

class _ExplodingBlock with HasGameData, GameParticle, ManagedGameParticle {
  static late BlockContainer container;

  @override
  bool get loop => false;

  void move_up() => y -= 1;

  void move_down() => y += 1;

  // GameParticle

  @override
  void update_while_active() => container.erase_block(x.toInt(), y.toInt());

  @override
  void on_completed() => container.erase_block(x.toInt(), y.toInt());
}
