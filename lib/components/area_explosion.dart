import 'package:flame/components.dart';
import 'package:flame/particles.dart';

import '../../core/functions.dart';
import '../core/random.dart';
import 'explosion_particle.dart';

/// Continuously spawns [ExplosionParticle]s at random positions inside the given [_area].
class AreaExplosion extends ComposedParticle {
  final PositionComponent _area;
  final SpriteAnimation _anim;

  double spawn_interval = 0.1;

  AreaExplosion(this._area, this._anim) : super(children: [], lifespan: 0x40000000);

  static Future<AreaExplosion> covering(PositionComponent area) async {
    final animation = await loadAnimCR('game_explosion.png', 9, 1);
    return AreaExplosion(area, animation);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawn_time -= dt;
    if (_spawn_time <= 0) {
      final pos = Vector2.random(rng)..multiply(_area.size);
      pos.add(_area.position);
      children.add(ExplosionParticle.from(_anim, pos));
      _spawn_time += spawn_interval;
    }
  }

  late double _spawn_time = spawn_interval;
}
