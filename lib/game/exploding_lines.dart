import 'dart:ui';

import '../core/common.dart';
import 'block_container.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_object.dart';
import 'game_particles.dart';

class ExplodingLines extends GameParticles<_ExplodingLine> {
  ExplodingLines() : super(_ExplodingLine.new);

  void trigger_at(int row, int sequence_index) {
    final int tickOffset = (sequence_index - 1) * tps ~/ 8;
    final int tickDuration = (5 - sequence_index) * tps ~/ 8;
    exploding_blocks.spawn_full_row(row, tickOffset, tickDuration);
    _trigger(row, tickOffset + tickDuration);
  }

  void _trigger(int aLineIndex, int aTicksFromNow) => require_particle()
    ..init(aLineIndex)
    ..init_timing(0, tps)
    ..activate();

  void on_line_inserted() => active_particles.forEach((it) => it.move_up());

  void on_line_removed(int aLineIndex) {
    for (final it in active_particles) {
      if (it.line_index < aLineIndex) it.move_down();
      if (it.line_index == aLineIndex) it.active = false;
    }
  }

  @override
  onLoad() => _ExplodingLine.container = container;

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      sprite_drawer.draw_exploding_at(canvas, it.x, it.y, it.progress);
    }
  }
}

class _ExplodingLine with HasGameData, GameParticle, ManagedGameParticle {
  static late BlockContainer container;

  @override
  bool get loop => false;

  late int line_index;

  init(int line_index) {
    this.line_index = line_index;
    init_timing(0, tps);
    activate();
  }

  void move_up() => line_index--;

  void move_down() => line_index++;

  // GameParticle

  @override
  void update_while_active() {}

  @override
  void on_completed() => container.clear_exploded_line(line_index);

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    line_index = data['line_index'];
  }

  @override
  GameData save_state(GameData data) => super.save_state(data)..['line_index'] = line_index;
}
