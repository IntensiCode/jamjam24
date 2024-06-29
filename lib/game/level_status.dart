import 'dart:ui';

import 'package:flame/components.dart';

import '../components/area_explosion.dart';
import '../components/soft_keys.dart';
import '../core/common.dart';
import '../scripting/game_script.dart';
import '../util/extensions.dart';
import '../util/fonts.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'keys.dart';

class LevelStatus extends GameScriptComponent with KeyboardHandler, HasGameKeys {
  LevelStatus(this._proceed);

  final void Function(SoftKey) _proceed;

  double _key_delay = 2;

  @override
  onLoad() async {
    fontSelect(menuFont);
    if (model.state == GameState.level_complete) {
      textXY('Level Complete', xCenter, yCenter);
    }
    if (model.state == GameState.hiscore) {
      final box = added(RectangleComponent(
        position: Vector2(xCenter, yCenter),
        size: Vector2(gameWidth * 2 / 3, gameHeight / 4),
        anchor: Anchor.center,
        paint: Paint()..color = transparent,
      ));
      textXY('Hiscore!', xCenter, yCenter);
      add(Particles(await AreaExplosion.covering(box))..priority = -10);
    }
    if (model.state == GameState.game_over) {
      textXY('Game Over', xCenter, yCenter);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_key_delay > 0) {
      _key_delay -= dt;
    } else {
      if (fire1 || fire2) _proceed(SoftKey.right);
    }
  }
}
