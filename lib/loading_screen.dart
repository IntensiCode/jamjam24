import 'package:flame/components.dart';
import 'package:flutter/animation.dart';

import 'core/common.dart';
import 'core/screens.dart';
import 'core/soundboard.dart';
import 'input/shortcuts.dart';
import 'scripting/game_script.dart';
import 'util/fonts.dart';

class LoadingScreen extends GameScriptComponent with HasAutoDisposeShortcuts {
  @override
  void onLoad() async {
    fontSelect(menuFont, scale: 1);

    late SpriteAnimationComponent anim;

    at(0.0, () => fadeIn(textXY('An', xCenter, yCenter - lineHeight)));
    at(0.8, () => fadeIn(textXY('IntensiCode', xCenter, yCenter)));
    at(1.2, () => fadeIn(textXY('Presentation', xCenter, yCenter + lineHeight)));
    at(2.0, () => fadeOutAll(0.6));
    at(1.0, () => playAudio('swoosh.ogg'));
    at(0.1, () async => anim = await _loadAnimation());
    at(0.0, () => fadeIn(textXY('A', xCenter, yCenter - lineHeight * 4)));
    at(0.0, () => fadeIn(textXY('Game', xCenter, yCenter + lineHeight * 4)));
    at(0.5, () => playAudio('psychocell.ogg'));
    at(1.5, () => scaleTo(anim, 10, 1, Curves.decelerate));
    at(0.0, () => fadeOutAll());
    at(0.5, () => _leave());

    onKey('<Space>', () => _leave());
  }

  void _leave() {
    showScreen(Screen.audio_menu, skip_fade_out: true);
    removeFromParent();
  }

  Future<SpriteAnimationComponent> _loadAnimation() async {
    final anim = await makeAnimCRXY('psychocell_anim.png', 13, 1, xCenter, yCenter, loop: false, stepTime: 0.05);
    anim.scale.setAll((gameWidth / 2 ~/ anim.width).toDouble());
    return anim;
  }

  @override
  void onMount() {
    super.onMount();
    soundboard.master = 0.75;
    soundboard.music = 0.5;
    soundboard.muted = false;
    soundboard.sound = 0.75;
    soundboard.voice = 0.75;
  }

  @override
  void onRemove() {
    super.onRemove();
    images.clear('psychocell_anim.png');
    soundboard.clear('swoosh.ogg');
  }
}
