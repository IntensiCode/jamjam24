import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/game.dart';
import '../core/random.dart';
import '../scripting/game_script.dart';
import '../util/extensions.dart';
import 'bubbles.dart';
import 'game_controller.dart';

class ColumnBubbles extends GameScriptComponent {
  static const _inset = 10.0;
  
  final _bubbles = Bubbles();

  late final Vector2 _left;
  late final Vector2 _right;
  late final FloatSize _area;

  double _spawn_time = 0;

  @override
  onLoad() async {
    _left = visual.left_colum_position;
    await spriteXY('skin_left.png', _left.x, _left.y, Anchor.topLeft);

    _right = visual.right_colum_position;
    final column = await spriteXY('skin_right.png', _right.x, _right.y, Anchor.topRight);

    _area = FloatSize(column.width - _inset * 2, column.height - 10);

    add(_bubbles);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final count = _bubbles.active_particles_count();
    if (count >= visual.side_bubbles) return;

    if (_spawn_time <= 0) {
      _add_bubble();
      _spawn_time = rng.nextDoubleLimit(0.2);
    } else {
      _spawn_time -= dt;
    }
  }

  void _add_bubble() {
    final side = rng.nextBool();
    final base = side ? _left : _right;
    final x = (_inset + rng.nextDoubleLimit(_area.width)) * (side ? 1 : -1);
    final drift = _area.height * 0.1 + rng.nextDoubleLimit(_area.height * 0.2);
    final wobble = rng.nextDoubleLimit(2);
    _bubbles.require_particle()
      ..init_position(base.x + x, base.y + _area.height)
      ..init_timing(0, tps * 4 + rng.nextInt(tps * 3))
      ..init(drift, wobble)
      ..activate();
  }
}
