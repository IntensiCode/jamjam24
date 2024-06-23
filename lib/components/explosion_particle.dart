import 'package:flame/components.dart';
import 'package:flame/particles.dart';

/// Non-looped "jumping" explosion running for two seconds.
class ExplosionParticle extends AcceleratedParticle {
  ExplosionParticle(SpriteAnimationParticle child)
      : super(child: child, speed: Vector2(0, -50), acceleration: Vector2(0, 50), lifespan: 2);

  factory ExplosionParticle.from(SpriteAnimation anim, Vector2 pos) =>
      ExplosionParticle(SpriteAnimationParticle(animation: anim, position: pos));
}
