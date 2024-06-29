import 'package:flame/components.dart';

import '../core/common.dart';
import 'game_model.dart';
import 'game_object.dart';

class ClearAll extends Component with GameObject {
  late int _last_clear_index;
  late int _clear_tick_counter;
  late int _clear_duration_in_ticks;
  late bool _running;

  void trigger() {
    _last_clear_index = container.height;
    _clear_tick_counter = _clear_duration_in_ticks = tps * 2;
    _running = true;
  }

  void on_line_inserted() => _last_clear_index--;

  // Component

  @override
  void update(double dt) {
    if (!_running) return;

    if (_clear_tick_counter == 0) {
      _running = false;
    } else {
      _clear_tick_counter--;
    }

    final c = container;
    final width = c.width;
    final height = c.height;

    final current_index = _clear_tick_counter * height ~/ _clear_duration_in_ticks;
    if (_last_clear_index == current_index) return;

    for (int idx = current_index; idx < _last_clear_index; idx++) {
      for (int above = 0; above < width / 2; above++) {
        final int y = idx - above ~/ 2;
        if (y < 0) continue;
        for (int x = above; x < width - above; x++) {
          c.explode_block(x, y);
        }
      }
    }

    _last_clear_index = current_index;
  }

  // GameObject

  @override
  void on_start_new_game() {
    _last_clear_index = container.height;
    _clear_tick_counter = _clear_duration_in_ticks = tps * 2;
    _running = false;
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    _last_clear_index = data['last_clear_index'];
    _clear_tick_counter = data['clear_tick_counter'];
    _clear_duration_in_ticks = data['clear_duration_in_ticks'];
    _running = data['running'];
  }

  @override
  GameData save_state(GameData data) => data
    ..['last_clear_index'] = _last_clear_index
    ..['clear_tick_counter'] = _clear_tick_counter
    ..['clear_duration_in_ticks'] = _clear_duration_in_ticks
    ..['running'] = _running;
}
