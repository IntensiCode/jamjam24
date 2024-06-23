import 'dart:ui';

import '../core/common.dart';
import '../core/game.dart';
import '../core/random.dart';
import '../util/extensions.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'game_particles.dart';

class Explosions extends GameParticles<_Explosion> {
  Explosions() : super(_Explosion.new);

  void spawn_at(double x, double y, int duration_in_ticks) => require_particle()
    ..init_position(x, y)
    ..init_timing(0, duration_in_ticks)
    ..activate();

  void spawn_for_row(int aLineIndex, int aLineCount) {
    const ticks = tps * 3 ~/ 4;
    final width = container.width;
    for (int x = 0; x < width; x++) {
      final tile = container.rows[aLineIndex][x];
      if (tile == PlacedBlockId.EMPTY) continue;

      final tickIndex = (x < width / 2) ? x : (width - 1 - x);
      final tickDelay = tickIndex * ticks / (width - 1) ~/ 2;

      final xPos = x + 0.5;
      final yPos = aLineIndex + 0.5;

      require_particle()
        ..set_speed_y(-(aLineCount + 1) * _Explosion._jump_step / 5)
        ..init_position(xPos, yPos)
        ..init_timing(tickDelay, ticks * 2)
        ..activate();

      require_particle()
        ..set_speed_y(-(aLineCount + 1) * _Explosion._jump_step / 7)
        ..init_position(xPos + 0.5, yPos)
        ..init_timing(tickDelay ~/ 2, ticks)
        ..activate();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      sprite_drawer.draw_explosion_at(canvas, it.x, it.y, it.progress);
    }
  }
}

class _Explosion with HasGameData, GameParticle, ManagedGameParticle {
  static const _jump_step = 16.0;
  static const _fall_speed = 32.0;

  @override
  bool get loop => false;

  late double _speed_x;
  late double _speed_y;

  void set_speed_y(double speed) => set_speed(0, speed);

  void set_speed(double speed_x, double speed_y) {
    _speed_x = speed_x;
    _speed_y = speed_y;
    _speed_x += rng.nextDoublePM(_jump_step / 2);
    _speed_y -= rng.nextDoubleLimit(_jump_step);
  }

  // GameParticle

  @override
  void reset() {
    super.reset();
    _speed_x = _speed_y = 0;
  }

  @override
  void update_while_active() {
    x += _speed_x / tps;
    y += _speed_y / tps;
    _speed_y += _fall_speed / tps;
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    _speed_x = data['speed_x'];
    _speed_y = data['speed_y'];
  }

  @override
  GameData save_state(GameData data) => super.save_state(data
    ..['speed_x'] = _speed_x
    ..['speed_y'] = _speed_y);
}
