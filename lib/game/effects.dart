import 'package:flame/components.dart';

import '../components/delayed.dart';
import '../core/common.dart';
import '../core/messaging.dart';
import '../core/soundboard.dart';
import '../scripting/game_script.dart';
import '../scripting/game_script_functions.dart';
import '../util/extensions.dart';

extension ScriptFunctionsExtension on GameScriptFunctions {
  Effects effects() => added(Effects());
}

extension ComponentExtensions on Component {
  void spawnEffect(
    EffectKind kind,
    Vector2 position, {
    double? delaySeconds,
    Function()? atHalfTime,
    Vector2? velocity,
  }) {
    messaging.send(SpawnEffect(
      kind: kind,
      position: position,
      delaySeconds: delaySeconds,
      atHalfTime: atHalfTime,
      velocity: velocity,
    ));
  }
}

class Effects extends GameScriptComponent {
  late final animations = <EffectKind, SpriteAnimation>{};

  @override
  void onLoad() async {
    animations[EffectKind.explosion] = await loadAnimWH('explosion96.png', 96, 96, 0.1, false);
    animations[EffectKind.smoke] = await loadAnimWH('smoke.png', 64, 64, 0.05, false);
    animations[EffectKind.sparkle] = await loadAnimWH('sparkle.png', 16, 16, 0.1, false);
  }

  @override
  void onMount() {
    super.onMount();
    onMessage<SpawnEffect>((data) {
      final it = _pool.removeLastOrNull() ?? Effect(_recycle);
      it.kind = data.kind;
      it.anim.animation = animations[data.kind]!;
      it.atHalfTime = data.atHalfTime;
      it.velocity = data.velocity;
      it.position.setFrom(data.position);

      final delay = data.delaySeconds ?? 0.0;
      add(delay == 0 ? it : Delayed(delay, it));
    });
  }

  void _recycle(Effect it) {
    it.removeFromParent();
    _pool.add(it);
  }

  final _pool = <Effect>[];
}

class Effect extends PositionComponent {
  Effect(this._recycle) {
    anchor = Anchor.center;
    add(anim);
  }

  final anim = SpriteAnimationComponent(anchor: Anchor.center);

  final void Function(Effect) _recycle;

  late EffectKind kind;
  Function()? atHalfTime;
  Vector2? velocity;

  @override
  void onMount() {
    switch (kind) {
      case EffectKind.explosion:
        anim.scale = Vector2.all(10.0);
      case EffectKind.smoke:
        anim.scale = Vector2.all(5);
      case EffectKind.sparkle:
        anim.scale = Vector2.all(25);
      default:
        anim.scale = Vector2.all(10.0);
    }
    anim.animationTicker!.reset();
    anim.animationTicker!.onComplete = () => _recycle(this);
    if (atHalfTime != null) {
      anim.animationTicker!.onFrame = (it) {
        if (it >= anim.animation!.frames.length ~/ 2) {
          atHalfTime!();
          anim.animationTicker!.onFrame = null;
        }
      };
    }
    if (kind == EffectKind.explosion) soundboard.play(Sound.explosion);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (velocity != null) position.add(velocity! * dt);
  }
}
