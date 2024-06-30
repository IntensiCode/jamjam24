import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/game.dart';
import '../input/game_keys.dart';
import 'game_configuration.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'placed_tile.dart';
import 'tile.dart';

enum PlayerState {
  playing,
  next_tile,
  game_over;

  static PlayerState from(final String name) => PlayerState.values.firstWhere((e) => e.name == name);
}

class Player extends Component with GameObject {
  int score = 0;
  int detonators = 0;
  int detonate_timer = 0;

  int _slow_down = 0;
  int _step_delay = 0;

  int _tile_step_ticks = 0;

  final active_tile = PlacedTile();

  var state = PlayerState.playing;

  bool get is_blocked => state == PlayerState.game_over;

  void on_new_bomb() => detonators++;

  void on_slow_down() => _slow_down += (level.level_number_starting_at_1 + 2) ~/ 3;

  void on_score_bonus() => score += level.score_bonus();

  void on_score_lines(int removed) => score += level.score_removed_lines(removed);

  void on_score_placed_tile() => player.score += level.score_placed_tile();

  void on_special_extra(ExtraId id) => score += level.score_special_extra(id);

  // Component

  @override
  void update(double dt) {
    if (model.state != GameState.playing_level) return;

    switch (state) {
      case PlayerState.playing:
        _on_playing();
      case PlayerState.next_tile:
        _on_next_tile();
      case PlayerState.game_over:
        break;
    }

    if (detonate_timer > 0) detonate_timer--;
  }

  // GameObject

  @override
  void on_start_new_game() {
    logInfo('on_start_new_game');
    active_tile.reset();
    state = PlayerState.playing;
    detonators = configuration.detonators_at_start;
    detonate_timer = 0;
    _slow_down = 0;
    _tile_step_ticks = 0;
    score = 0;
  }

  @override
  void on_resume_game() {
    logInfo('on_resume_game');
    state = PlayerState.playing;
    // _on_next_tile();
  }

  @override
  void on_start_playing() {
    logInfo('on_start_playing');
    super.on_start_playing();
    state = PlayerState.playing;
    _on_next_tile();
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    score = data['score'];
    detonators = data['detonators'];
    _slow_down = data['slow_down'];
    _step_delay = data['step_delay'];
    detonate_timer = data['detonate_timer'];
    state = PlayerState.from(data['state']);
    _tile_step_ticks = data['tile_step_ticks'];
    active_tile.load_state(data['active_tile']);
    _moved_tile.load_state(data['moved_tile']);
  }

  @override
  GameData save_state(GameData data) => data
    ..['score'] = score
    ..['detonators'] = detonators
    ..['slow_down'] = _slow_down
    ..['step_delay'] = _step_delay
    ..['detonate_timer'] = detonate_timer
    ..['state'] = state.name
    ..['tile_step_ticks'] = _tile_step_ticks
    ..['active_tile'] = active_tile.save_state({})
    ..['moved_tile'] = _moved_tile.save_state({});

  // Implementation

  void _on_playing() {
    if (configuration.drop_hint_mode == DropHint.always) {
      active_tile.draw_drop_guide = true;
    }

    if (!active_tile.is_still_valid) return;

    _control_using_keys();

    if (active_tile.draw_drop_guide) _update_drop_guide();

    if (keys.check_and_consume(GameKey.fire1)) _drop_tile();
    if (keys.check_and_consume(GameKey.fire2)) _detonate_tile();

    _update_step_delay();

    if (_tile_step_ticks < _step_delay) {
      _tile_step_ticks++;
    } else {
      _move_tile_down();
    }
  }

  void _update_drop_guide() {
    final guide = active_tile.drop_guide ??= PlacedTile();

    final rotation_changed = guide.rotation != active_tile.rotation;
    final tile_changed = guide.tile != active_tile.tile;
    if (rotation_changed || tile_changed || guide.position.x != active_tile.position.x) {
      guide.init_(active_tile);
      guide.ghost = true;
    }

    // if (container.changed_for_player) {
    guide.position.y = active_tile.position.y;

    while (container.can_be_placed(guide)) {
      guide.position.y++;
    }
    guide.position.y--;

    if (guide.position.y <= active_tile.position.y) {
      guide.reset();
    }
    // }
  }

  void _update_step_delay() {
    final slow_down_millis = configuration.slow_down_in_millis * _slow_down;
    final slow_down_factor = slow_down_millis / 1000;
    final step_delay_fixed = level.step_delay_in_seconds + slow_down_factor;
    final was = _step_delay;
    _step_delay = (step_delay_fixed * tps).toInt();
    if (_step_delay != was) {
      logInfo('update step delay: $_step_delay (ticks)');
      logInfo('step_delay_in_seconds = ${level.step_delay_in_seconds}');
      logInfo('slow_down_factor = $slow_down_factor');
    }
  }

  void _control_using_keys() {
    if (keys.check_and_consume(GameKey.left)) _move_if_valid(-1, 0);
    if (keys.check_and_consume(GameKey.right)) _move_if_valid(1, 0);
    if (keys.check_and_consume(GameKey.down)) _move_tile_down();
    if (keys.check_and_consume(GameKey.up)) _rotate_tile();
  }

  void _on_next_tile() {
    if (active_tile.is_still_valid) {
      active_tile.position.set_to(container.start_position);
      state = PlayerState.playing;
      return;
    }

    // if a tile just dropped, wait for it to move enough before showing the new tile:
    for (final it in dropped_tiles.active_particles) {
      if (it.tile.pos_y < Tile.MAX_TILE_SIZE * 2) return;
    }

    level.on_next_tile();
    active_tile.init(level.current_tile, container.start_position);
    _tile_step_ticks = 0;

    state = container.can_be_placed(active_tile) ? PlayerState.playing : PlayerState.game_over;
  }

  void _move_tile_down() {
    final moved = _move_if_valid(0, 1);
    if (moved) {
      _tile_step_ticks = 0;
    } else {
      container.place_tile(active_tile);
      active_tile.reset();
      state = PlayerState.next_tile;
    }
  }

  void _rotate_tile() {
    final cw = configuration.rotate_clock_wise;
    final rotation = TileRotation.rotate(active_tile.rotation, cw);
    if (_move_if_valid(0, 0, rotation)) return;
    if (!configuration.rotate_can_move) return;

    if (_move_if_valid(1, 0, rotation)) return;
    if (_move_if_valid(-1, 0, rotation)) return;
    if (active_tile.height > 3) _move_if_valid(2, 0, rotation);
  }

  void _drop_tile() {
    final drop_interval = configuration.tile_drop_delay_in_millis * tps ~/ 1000;
    dropped_tiles.drop(active_tile, drop_interval);

    active_tile.reset();
    state = PlayerState.next_tile;
  }

  void _detonate_tile() {
    bool can_detonate = detonators > 0 && detonate_timer <= 0;
    if (!can_detonate) return;

    container.detonate(active_tile);

    detonators--;
    detonate_timer = (configuration.detonate_timer_in_millis * tps ~/ 1000);

    active_tile.reset();
    state = PlayerState.next_tile;
  }

  bool _move_if_valid(int delta_x, int delta_y, [TileRotation? rotation]) {
    final x = active_tile.position.x + delta_x;
    final y = active_tile.position.y + delta_y;
    _moved_tile.init__(active_tile.tile, rotation ?? active_tile.rotation, x, y);

    if (!container.can_be_placed(_moved_tile)) return false;

    active_tile.position.x = x;
    active_tile.position.y = y;
    active_tile.rotation = rotation ?? active_tile.rotation;

    return true;
  }

  final _moved_tile = PlacedTile();
}
