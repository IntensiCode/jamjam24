import 'dart:math';
import 'dart:ui';

import '../core/common.dart';
import '../core/game.dart';
import '../util/math_extended.dart';
import 'block_container.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'game_particles.dart';

class DetonatingBlocks extends GameParticles<_DetonatingBlock> {
  DetonatingBlocks() : super(_DetonatingBlock.new);

  void detonate_at(int aX, int aY) {
    final radius = configuration.detonate_radius;
    final xStart = max(0, aX - radius);
    final xEnd = min(container.width, aX + radius);
    final yStart = max(0, aY - radius);
    final yEnd = min(container.height, aY + radius);

    for (int y = yStart; y < yEnd; y++) {
      final xOffset = (y & 1) == 1 ? -0.5 : 0.5;
      for (int x = xStart; x < xEnd; x++) {
        final id = container.rows[y][x];
        if (id == PlacedBlockId.EMPTY) continue;
        if (id == PlacedBlockId.EXPLODED) continue;

        final xCenterFixed = aX + xOffset;
        final yCenterFixed = aY + 1.0;

        require_particle()
          ..init(x.toDouble(), y.toDouble(), id)
          ..init_detonate_from(xCenterFixed, yCenterFixed)
          ..activate();

        container.rows[y][x] = PlacedBlockId.EMPTY;
      }
    }
  }

  @override
  onLoad() => _DetonatingBlock.container = container;

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      sprite_drawer.draw_block_at(canvas, it.x, it.y, it._id);
    }
  }
}

class _DetonatingBlock with HasGameData, GameParticle, ManagedGameParticle {
  static late BlockContainer container;

  @override
  bool get loop => true;

  static const _fall_speed = 12.0;
  static const _detonate_speed = _fall_speed * 2;

  late PlacedBlockId _id;
  late int _retry_count;
  late double _speed_x;
  late double _speed_y;

  int get _pos_x => x.round();

  int get _pos_y => y.round();

  void init(double x, double y, PlacedBlockId id) {
    init_position(x, y);
    _id = id;
    _speed_x = _speed_y = 0;
    _retry_count = 5;
  }

  void init_detonate_from(double origin_x, double origin_y) {
    init_timing(0, tps * 2);

    final delta_x = x - origin_x;
    final delta_y = y - origin_y;
    final length = MathExtended.length(delta_x, delta_y);
    final real_length = length == 0 ? 0.25 : length;
    const intensity = _detonate_speed;
    final x_intensity = max(intensity / 4, intensity / 1 + delta_x.abs());
    final y_intensity = max(intensity, intensity / 1 + delta_y.abs());
    final x_real_intensity = x_intensity == 0 ? 0.25 : x_intensity;
    final y_real_intensity = y_intensity == 0 ? 0.25 : y_intensity;
    _speed_x = ((delta_x / real_length) * x_real_intensity);
    _speed_y = ((delta_y / real_length) * y_real_intensity);
  }

  // GameParticle

  @override
  void update_while_active() {
    if (container.is_blocked(_pos_x, _pos_y)) {
      x = _pos_x.toDouble();
      y = _pos_y.toDouble();
      active = false;
      return;
    }

    final x_step = _speed_x / tps;
    final y_step = _speed_y / tps;
    final maxPosX = container.width - 1.0;
    final maxPosY = container.height - 1.0;
    final newPosX = x + x_step;
    final newPosY = y + y_step;
    final newX = newPosX.round();
    final newY = newPosY.round();

    if (newPosX < 0 || newPosX > maxPosX) {
      _speed_x = -_speed_x * 3 / 4;
      x = newPosX.clamp(0, maxPosX);
      return;
    }

    if (newPosY < 0) {
      _speed_y = -_speed_y;
      y = 0;
      return;
    }

    if (newPosY > maxPosY) {
      container.place_block(_pos_x, _pos_y, _id);
      x = _pos_x.toDouble();
      y = _pos_y.toDouble();
      active = false;
      return;
    }

    if (container.is_blocked(newX, newY)) {
      if (_retry_count > 0) {
        _retry_count--;
        x = _pos_x.toDouble();
        _speed_x = 0;
        return;
      } else {
        container.place_block(_pos_x, _pos_y, _id);
        x = _pos_x.toDouble();
        y = _pos_y.toDouble();
        active = false;
        return;
      }
    }

    if (_speed_x.abs() < _fall_speed / 4 && _speed_y > 0) {
      if (container.is_blocked(_pos_x, newY + 1)) {
        container.place_block(_pos_x, newY, _id);
        x = _pos_x.toDouble();
        y = _pos_y.toDouble();
        active = false;
        return;
      }
    }

    _speed_x = _speed_x * 98 / 100;
    _speed_y += _fall_speed / 4;
    if (_speed_y > _fall_speed) _speed_y = _fall_speed * 2; // TODO ???

    x = newPosX.clamp(0, maxPosX);
    y = newPosY.clamp(0, maxPosY);
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    _id = PlacedBlockId.from(data['tile']);
    _retry_count = data['retry_count'] as int;
    _speed_x = data['speed_x'] as double;
    _speed_y = data['speed_y'] as double;
  }

  @override
  GameData save_state(GameData data) => super.save_state(data
    ..['tile'] = _id.name
    ..['retry_count'] = _retry_count
    ..['speed_x'] = _speed_x
    ..['speed_y'] = _speed_y);
}
