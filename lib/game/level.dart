import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/game.dart';
import '../core/random.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'placed_tile.dart';
import 'tile.dart';
import 'tile_set.dart';

class Level extends Component with GameObject {
  int level_number_starting_at_1 = 0;
  int remaining_lines_to_clear = 10;
  double step_delay_in_seconds = 0;
  final next_tile = PlacedTile();
  final current_tile = PlacedTile();

  int _lines_to_fill_in = 0;
  int _lines_fill_ticks = 0;

  bool get is_complete => remaining_lines_to_clear <= 0;

  int score_removed_lines(int count) {
    remaining_lines_to_clear -= count;
    return 9 + level_number_starting_at_1 * count * count;
  }

  int score_bonus() => level_number_starting_at_1 * 100;

  int score_placed_tile() => level_number_starting_at_1;

  int score_special_extra(ExtraId id) => level_number_starting_at_1 * 10 * id.index;

  void on_next_tile() {
    if (next_tile.is_valid_for_placement) {
      current_tile.tile = next_tile.tile;
      current_tile.rotation = next_tile.rotation;
    }

    if (configuration.pure_random) {
      next_tile.tile = TileSet.pick_random();
    } else {
      if (_original_random_tiles.isEmpty) _original_random_tiles.addAll(TileSet.tiles);

      final which = rng.nextInt(_original_random_tiles.length);
      next_tile.tile = _original_random_tiles.removeAt(which);
    }

    next_tile.rotation = TileRotation.pick_random();
  }

  final _original_random_tiles = <Tile>[];

  void advance() {
    final level_index = level_number_starting_at_1++;

    final config = configuration;
    final step_delay = config.tile_step_delay_in_millis - level_index * config.tile_step_interval_in_millis;
    step_delay_in_seconds = step_delay / 1000;
    logInfo('level $level_index step_delay_in_seconds = $step_delay_in_seconds');

    if (config.adapt_lines_to_clear) {
      final lines_to_clear = config.initial_lines_to_clear + level_index * config.lines_delta_per_level;
      remaining_lines_to_clear = lines_to_clear.clamp(config.min_lines_to_clear, config.max_lines_to_clear);
    } else {
      remaining_lines_to_clear = config.initial_lines_to_clear;
    }

    // rng.setSeed(level_index);

    _original_random_tiles.clear();
    if (!next_tile.is_valid_for_placement) on_next_tile();
  }

  void fill_in_full_row() {
    container.insert_bottom_line();
    container.make_death_row();
  }

  // Component

  @override
  void update(double dt) {
    if (_lines_to_fill_in == 0) return;

    if (_lines_fill_ticks < tps) {
      _lines_fill_ticks++;
    } else {
      _lines_fill_ticks = 0;
      _lines_to_fill_in--;
      fill_in_full_row();
    }
  }

  // GameObject

  @override
  void on_start_new_game() {
    level_number_starting_at_1 = 0;
    current_tile.reset();
    next_tile.reset();
    remaining_lines_to_clear = 0;
    step_delay_in_seconds = 0;
    advance();
  }

  @override
  void on_start_playing() {
    _lines_to_fill_in = ((level_number_starting_at_1 - 1) * 2) ~/ 5;
    _lines_to_fill_in = _lines_to_fill_in.clamp(0, configuration.max_fill_in_lines);
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    next_tile.load_state(data['next_tile']);
    current_tile.load_state(data['current_tile']);
    level_number_starting_at_1 = data['level_number_starting_at_1'];
    remaining_lines_to_clear = data['remaining_lines_to_clear'];
    step_delay_in_seconds = data['step_delay_in_seconds'];
    _lines_to_fill_in = data['lines_to_fill_in'];
    _lines_fill_ticks = data['lines_fill_ticks'];
  }

  @override
  GameData save_state(GameData data) => data
    ..['next_tile'] = next_tile.save_state({})
    ..['current_tile'] = current_tile.save_state({})
    ..['level_number_starting_at_1'] = level_number_starting_at_1
    ..['remaining_lines_to_clear'] = remaining_lines_to_clear
    ..['step_delay_in_seconds'] = step_delay_in_seconds
    ..['lines_to_fill_in'] = _lines_to_fill_in
    ..['lines_fill_ticks'] = _lines_fill_ticks;
}
