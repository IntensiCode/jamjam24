import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/game.dart';
import '../core/random.dart';
import '../core/soundboard.dart';
import '../util/extensions.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'game_particles.dart';
import 'placed_tile.dart';

class Extras extends GameParticles<Extra> {
  Extras() : super(Extra.new);

  spawn_in_row(final int row, final int clear_size) {
    final id = ExtraId.pick_random(clear_size);
    final x = rng.nextDoubleLimit(container.width - 1) + 0.5;
    final y = row + 0.5;
    require_particle().init(id, x, y);
  }

  void spawn(ExtraId id, double x, double y) => require_particle().init(id, x, y);

  @override
  void update(double dt) {
    for (final it in particles) {
      if (it.active && !it.isMounted) add(it);
    }
    super.update(dt);
    for (final it in particles) {
      if (!it.active && it.isMounted) remove(it);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      sprite_drawer.draw_extra_at(canvas, it.x - 0.5, it.y - 0.5, it._id, it.progress);
    }
  }
}

class Extra extends Component with HasGameData, GameParticle, ManagedGameParticle {
  static const _fall_speed = 12.0;

  @override
  bool get loop => true;

  late ExtraId _id;
  late double _speed_x;
  late double _speed_y;
  late bool _erase_blocks;

  void init(ExtraId id, double x, double y) {
    _id = id;
    _speed_x = rng.nextDoublePM(_fall_speed);
    _speed_y = -_fall_speed;
    _erase_blocks = false;
    init_position(x, y);
    init_timing(0, tps);
    activate();
  }

  void apply(PlacedTile tile, int duration_in_ticks) {
    final int particle_count = configuration.extra_particles;
    for (int idx = 0; idx < particle_count; idx++) {
      explosions.spawn_at(x, y, duration_in_ticks);
    }

    apply_extra(tile);

    active = _id == ExtraId.eraser;
  }

  void apply_extra(PlacedTile tile) {
    // score once when spawned in container, then again here when caught:
    player.on_special_extra(_id);

    switch (_id) {
      case ExtraId.detonate:
        _on_detonate(tile);
      case ExtraId.score_bonus:
        _on_score_bonus();
      case ExtraId.new_bomb:
        _on_new_bomb();
      case ExtraId.slow_down:
        _on_slow_down();
      case ExtraId.random:
        _on_random();
      case ExtraId.eraser:
        _on_eraser(tile);
      case ExtraId.death_row:
        _on_death_row();
      case ExtraId.clear:
        _on_clear();
    }
  }

  // GameParticle

  @override
  void update_while_active() {
    if (_erase_blocks) _on_erase_blocks();
    _bounce();
    _check_high_ball();
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    _id = ExtraId.from(data['id']);
    _speed_x = data['speed_x'];
    _speed_y = data['speed_y'];
    _erase_blocks = data['erase_blocks'];
  }

  @override
  GameData save_state(GameData data) => super.save_state(data
    ..['id'] = _id.name
    ..['speed_x'] = _speed_x
    ..['speed_y'] = _speed_y
    ..['erase_blocks'] = _erase_blocks);

  // Implementation

  void _on_detonate(PlacedTile tile) {
    _show_extra_info('DETONATION');
    soundboard.trigger(Sound.detonate);
    container.detonate(tile);
  }

  void _on_score_bonus() {
    _show_extra_info('SCORE BONUS');
    soundboard.trigger(Sound.score);
    player.on_score_bonus();
  }

  void _on_new_bomb() {
    _show_extra_info('NEW BOMB');
    soundboard.trigger(Sound.bomb);
    player.on_new_bomb();
  }

  void _on_slow_down() {
    _show_extra_info('SLOW DOWN');
    soundboard.trigger(Sound.slowdown);
    player.on_slow_down();
  }

  void _on_random() {
    _show_extra_info('RANDOM');

    final extra = extras.require_particle();
    extra.init(ExtraId.pick_random(), x, y);

    if (extra._id == ExtraId.random) {
      soundboard.trigger(Sound.multi_random);
    } else {
      soundboard.trigger(Sound.random);
    }
  }

  void _on_eraser(PlacedTile tile) {
    if (_erase_blocks) {
      _id = ExtraId.detonate;
      _on_detonate(tile);
    } else {
      _show_extra_info('ERASER');
      _erase_blocks = true;
      soundboard.trigger(Sound.eraser);
    }
  }

  void _on_death_row() {
    _show_extra_info('DEATH ROW');
    soundboard.trigger(Sound.death_row);
    container.make_death_row(y.round());
  }

  void _on_clear() {
    _show_extra_info('CLEAR ALL');
    soundboard.trigger(Sound.clear);
    clear_all.trigger();
  }

  void _on_erase_blocks() {
    for (int idx = 0; idx < 9; idx++) {
      final dx = ((idx % 3) - 1) * 0.25;
      final dy = ((idx / 3) - 1) * 0.25;
      final at_x = (x + dx).round();
      final at_y = (y + dy).round();
      container.erase_block(at_x, at_y);
    }
  }

  void _bounce() {
    _speed_y += _fall_speed / tps / 2;
    final new_x = x + _speed_x / tps / 2;
    final new_y = y + _speed_y / tps / 2;
    if (new_x < 0.5 || new_x > container.width - 0.5) {
      _speed_x = -_speed_x * 80 / 100;
    }
    if (new_y > container.height - 0.5) {
      _speed_y = -_speed_y * 80 / 100;
    }
    x = new_x.clamp(0.5, container.width - 0.5);
    y = min(new_y, container.height - 0.5);

    if (_speed_y.abs() < 0.5 && (y + 0.5) >= container.height) {
      active = false;
      smoke.spawn_at(x, y);
    }
  }

  void _check_high_ball() {
    if (y > 1 || _id != ExtraId.random) return;
    y = 1;
    _show_extra_info('HIGH BALL');
    soundboard.trigger(Sound.highball);
    _drop_all_extras();
    reset();
  }

  void _drop_all_extras() {
    for (final it in ExtraId.values) {
      if (it != ExtraId.random) _drop_extra(it);
    }
  }

  void _drop_extra(ExtraId id) {
    final extra = extras.require_particle();
    extra.init(id, x, y);
    extra._speed_y = _fall_speed * 2 / 3 + rng.nextDoubleLimit(_fall_speed / 2);
  }

  void _show_extra_info(String text) => letters.pop_up_text(text, x, y);
}
