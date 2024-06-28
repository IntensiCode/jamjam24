

enum DropHint {
  always,
  never,
  touch_only,
}

class GameConfiguration {
  bool pure_random = false;
  bool adapt_lines_to_clear = false;
  bool explode_lines = true;
  bool key_repeat = true;
  bool key_repeat_slow = false;
  bool rotate_can_move = true;
  bool rotate_clock_wise = false;

  int detonate_particles = 8;
  int detonate_radius = 7;
  int detonate_timer_in_millis = 3000;
  int detonators_at_start = 5;
  int explode_block_time_in_millis = 250;
  int explode_lines_time_in_millis = 100;
  int extra_particles = 4;
  int initial_lines_to_clear = 10;
  int max_fill_in_lines = 10;
  int lines_delta_per_level = -1;
  int max_lines_to_clear = 20;
  int min_lines_to_clear = 5;
  int slow_down_in_millis = 3;
  int tile_drop_delay_in_millis = 25;
  int tile_step_delay_in_millis = 750;
  int tile_step_interval_in_millis = 50;

  DropHint drop_hint_mode = DropHint.always;
}
