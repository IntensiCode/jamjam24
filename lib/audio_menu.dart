import 'package:flame/components.dart';

import 'components/basic_menu.dart';
import 'components/soft_keys.dart';
import 'core/common.dart';
import 'core/functions.dart';
import 'core/screens.dart';
import 'core/soundboard.dart';
import 'scripting/game_script.dart';
import 'util/extensions.dart';
import 'util/fonts.dart';

enum AudioMenuEntry {
  music_and_sound,
  music_only,
  sound_only,
  silent_mode,
}

class AudioMenu extends GameScriptComponent {
  final bool _show_back;

  AudioMenu({required show_back}) : _show_back = show_back;

  @override
  onLoad() async {
    fontSelect(menuFont, scale: 1);
    textXY('Audio Mode', xCenter, lineHeight * 2, scale: 1.5);

    final buttonSheet = await sheetI('button_menu.png', 1, 2);
    final menu = added(BasicMenu<AudioMenuEntry>(buttonSheet, menuFont, _selected)
      ..addEntry(AudioMenuEntry.music_and_sound, 'Music & Sound')
      ..addEntry(AudioMenuEntry.music_only, 'Music Only')
      ..addEntry(AudioMenuEntry.sound_only, 'Sound Only')
      ..addEntry(AudioMenuEntry.silent_mode, 'Silent Mode')
      ..preselectEntry(AudioMenuEntry.sound_only));

    menu.position.setValues(xCenter, yCenter);
    menu.anchor = Anchor.center;

    if (_show_back) softkeys('Back', null, (_) => popScreen());
  }

  void _selected(AudioMenuEntry it) {
    switch (it) {
      case AudioMenuEntry.music_and_sound:
        break;
      case AudioMenuEntry.music_only:
        soundboard.sound = 0.0;
        soundboard.voice = 0.0;
        break;
      case AudioMenuEntry.sound_only:
        soundboard.music = 0.0;
        break;
      case AudioMenuEntry.silent_mode:
        soundboard.muted = true;
        break;
    }
    popScreen();
  }
}
