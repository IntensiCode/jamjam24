import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';

import '../util/bitmap_font.dart';
import '../util/bitmap_text.dart';
import '../util/effects.dart';
import '../util/extensions.dart';

class BasicMenuButton extends SpriteComponent with HasVisibility, TapCallbacks {
  final SpriteSheet sheet;
  final BitmapFont font;
  final Function onTap;

  BasicMenuButton(
    String text, {
    required this.sheet,
    required this.font,
    required this.onTap,
    bool selected = false,
  }) {
    this.selected = selected;
    add(BitmapText(
      text: text,
      position: size / 2,
      font: font,
      anchor: Anchor.center,
    ));
  }

  ComponentEffect? _highlighted;

  set selected(bool value) {
    if (value) {
      _highlighted ??= added(HighlightEffect());
      sprite = sheet.getSprite(0, 1);
    } else {
      _highlighted?.removeFromParent();
      _highlighted = null;
      sprite = sheet.getSprite(0, 0);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap();
  }
}
