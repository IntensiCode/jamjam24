import 'dart:ui';

import '../core/common.dart';
import '../util/fonts.dart';
import 'game_controller.dart';
import 'game_object.dart';
import 'game_particles.dart';

class PopUpLetters extends GameParticles<_PopUpLetter> {
  PopUpLetters() : super(_PopUpLetter.new);

  void pop_up_text(String text, double x, double y) {
    final length = text.length;
    for (int idx = 0; idx < length; idx++) {
      require_particle()
        ..init(text.codeUnitAt(idx), idx, length)
        ..init_position(x * visual.block_size.width, y * visual.block_size.height)
        ..init_timing(tps * idx ~/ length, tps * 5 ~/ 2)
        ..activate();
    }
  }

  @override
  render(Canvas canvas) {
    for (final it in active_particles) {
      final offset = it.char_index * fancyFont.lineHeight(2);
      final alignment = (it.text_length * fancyFont.lineHeight()) / 2;
      fancyFont.scale = 2;
      fancyFont.drawString(canvas, it.x + offset - alignment, it.y, String.fromCharCode(it.char_code));
    }
  }
}

class _PopUpLetter with HasGameData, GameParticle, ManagedGameParticle {
  static const _drop_speed_fixed = 10.0;

  @override
  bool get loop => false;

  int char_code = 0;
  int char_index = 0;
  int text_length = 0;

  double speed_y = 0;

  void init(int char_code, int char_index, int text_length) {
    this.char_code = char_code;
    this.char_index = char_index;
    this.text_length = text_length;
    speed_y = -_drop_speed_fixed / 4;
  }

  // GameParticle

  @override
  void update_while_active() {
    speed_y += _drop_speed_fixed / tps;
    y += speed_y;
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    char_code = data['char_code'];
    char_index = data['char_index'];
    text_length = data['text_length'];
    speed_y = data['speed_y'];
  }

  @override
  GameData save_state(GameData data) => super.save_state(data
    ..['char_code'] = char_code
    ..['char_index'] = char_index
    ..['text_length'] = text_length
    ..['speed_y'] = speed_y);
}
