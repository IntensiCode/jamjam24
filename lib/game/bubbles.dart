import 'dart:math';
import 'dart:ui';

import '../core/common.dart';
import '../core/random.dart';
import 'game_object.dart';
import 'game_particles.dart';

class Bubbles extends GameParticles<_Bubble> {
  Bubbles() : super(_Bubble.new);

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      it.render_while_active(canvas);
    }
  }
}

class _Bubble with HasGameData, GameParticle, ManagedGameParticle {
  static const _from = Color(0x800000ff);
  static const _to = Color(0xFFe0f0ff);

  static final _paint = pixelPaint()..style = PaintingStyle.stroke;

  @override
  bool get loop => false;

  late double _drift_speed;
  late double _wobble_index;
  late double _wobble_strength;
  late double _wobble_offset;
  late double _lifetime;

  init(double drift_speed, double wobble_strength) {
    _drift_speed = drift_speed;
    _wobble_strength = wobble_strength;
    _wobble_index = rng.nextDouble() * pi * 2;
    _lifetime = 0;
  }

  void render_while_active(Canvas canvas) {
    final a = (_lifetime * 2).clamp(0.0, 1.0);
    final c = Color.lerp(_from, _to, a)!;
    _paint.colorFilter = ColorFilter.mode(c, BlendMode.srcATop);

    final x_ = (x + _wobble_offset).roundToDouble();
    final y_ = y.roundToDouble();
    if (tick_counter >= tick_duration - 4) {
      canvas.drawCircle(Offset(x_, y_), 3, _paint);
    } else {
      canvas.drawCircle(Offset(x_, y_), 1, _paint);
    }
  }

  // ManagedGameParticle

  @override
  void update_while_active() {
    _lifetime += 1 / tps;
    y -= _drift_speed / tps;

    const full_circle = pi * 2;
    if (_wobble_index < full_circle) {
      _wobble_index += full_circle / tps;
    } else {
      _wobble_index -= full_circle;
    }

    _wobble_offset = sin(_wobble_index) * _wobble_strength;
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    _drift_speed = data['drift_speed'];
    _wobble_index = data['wobble_index'];
    _wobble_strength = data['wobble_strength'];
    _wobble_offset = data['wobble_offset'];
  }

  @override
  GameData save_state(GameData data) => super.save_state(data
    ..['drift_speed'] = _drift_speed
    ..['wobble_index'] = _wobble_index
    ..['wobble_strength'] = _wobble_strength
    ..['wobble_offset'] = _wobble_offset);
}
