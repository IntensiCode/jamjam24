import 'package:flame/components.dart';

import '../../util/auto_dispose.dart';
import '../util/bitmap_button.dart';
import '../util/fonts.dart';
import 'core/common.dart';
import 'core/screens.dart';
import 'input/shortcuts.dart';

class WebPlayScreen extends AutoDisposeComponent with HasAutoDisposeShortcuts {
  @override
  void onMount() => onKey('<Space>', () => _leave());

  @override
  onLoad() async {
    final button = await images.load('button_plain.png');
    const scale = 0.5;
    add(BitmapButton(
      bgNinePatch: button,
      text: 'Start',
      font: menuFont,
      fontScale: scale,
      position: Vector2(gameWidth / 2, gameHeight / 2),
      anchor: Anchor.center,
      onTap: (_) => _leave(),
    ));
  }

  void _leave() {
    showScreen(Screen.loading);
    removeFromParent();
  }
}
