import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import 'components/basic_menu.dart';
import 'core/common.dart';
import 'core/functions.dart';
import 'core/screens.dart';
import 'scripting/game_script.dart';
import 'util/extensions.dart';
import 'util/fonts.dart';

enum MainMenuEntry {
  resume_game,
  new_game,
  show_help,
  hiscore,
  options,
  audio_menu,
  back_to_title,
}

class MainMenu extends GameScriptComponent {
  static MainMenuEntry? _rememberSelection;

  @override
  onLoad() async {
    fontSelect(menuFont, scale: 1);
    textXY('Main Menu', xCenter, lineHeight * 2, scale: 1.5);

    final buttonSheet = await sheetI('button_menu.png', 1, 2);
    final menu = added(BasicMenu<MainMenuEntry>(buttonSheet, menuFont, _selected)
    // ..addEntry(MainMenuEntry.resume_game, 'Resume Game')
      ..addEntry(MainMenuEntry.new_game, 'New Game')
      ..addEntry(MainMenuEntry.show_help, 'Help')
      ..addEntry(MainMenuEntry.hiscore, 'Hiscore')
      ..addEntry(MainMenuEntry.options, 'Options')
      ..addEntry(MainMenuEntry.audio_menu, 'Audio Menu')
      ..addEntry(MainMenuEntry.back_to_title, 'Back to Title'));

    menu.position.setValues(xCenter, yCenter);
    menu.anchor = Anchor.center;

    _rememberSelection ??= menu.entries.first;

    menu.preselectEntry(_rememberSelection);
    menu.onPreselected = (it) => _rememberSelection = it;
  }

  void _selected(MainMenuEntry it) {
    logInfo('Selected: $it');
    switch (it) {
      case MainMenuEntry.resume_game:
        break;
      case MainMenuEntry.new_game:
        showScreen(Screen.game);
      case MainMenuEntry.show_help:
        break;
      case MainMenuEntry.hiscore:
        pushScreen(Screen.hiscore);
      case MainMenuEntry.options:
        break;
      case MainMenuEntry.audio_menu:
        pushScreen(Screen.audio_menu);
      case MainMenuEntry.back_to_title:
        popScreen();
    }
  }
}
