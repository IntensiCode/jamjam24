import 'package:flame/components.dart';

import 'components/area_explosion.dart';
import 'components/soft_keys.dart';
import 'core/common.dart';
import 'core/screens.dart';
import 'game/hiscore.dart';
import 'input/game_keys.dart';
import 'input/shortcuts.dart';
import 'scripting/game_script.dart';
import 'util/bitmap_font.dart';
import 'util/bitmap_text.dart';
import 'util/effects.dart';
import 'util/extensions.dart';
import 'util/fonts.dart';

class HiscoreScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, HasGameKeys {
  final _entry_size = Vector2(gameWidth, lineHeight);
  final _position = Vector2(0, lineHeight * 4);

  @override
  onLoad() async {
    fontSelect(menuFont, scale: 1);
    textXY('Hiscore', xCenter, lineHeight * 2, scale: 1.5);

    _add('Score', 'Level', 'Name');
    for (final entry in hiscore.entries) {
      final it = _add(entry.score.toString(), entry.level.toString(), entry.name);
      if (entry == hiscore.latestRank) {
        it.add(BlinkEffect(on: 0.75, off: 0.25));
        add(Particles(await AreaExplosion.covering(it))..priority = -10);
      }
    }

    softkeys('Back', null, (_) => popScreen());
  }

  _HiscoreEntry _add(String score, String level, String name) {
    final it = added(_HiscoreEntry(
      score,
      level,
      name,
      textFont,
      size: _entry_size,
      position: _position,
    ));
    _position.y += lineHeight;
    return it;
  }
}

class _HiscoreEntry extends PositionComponent with HasVisibility {
  final BitmapFont _font;

  _HiscoreEntry(
    String score,
    String level,
    String name,
    this._font, {
    required Vector2 size,
    super.position,
  }) : super(size: size) {
    add(BitmapText(
      text: score,
      position: Vector2(size.x * 5 / 32, 0),
      font: _font,
      anchor: Anchor.topCenter,
    ));

    add(BitmapText(
      text: level,
      position: Vector2(size.x * 13 / 32, 0),
      font: _font,
      anchor: Anchor.topCenter,
    ));

    add(BitmapText(
      text: name,
      position: Vector2(size.x * 24 / 32, 0),
      font: _font,
      anchor: Anchor.topCenter,
    ));
  }
}
