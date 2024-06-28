import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../util/extensions.dart';
import 'components/basic_menu.dart';
import 'components/basic_menu_button.dart';
import 'components/soft_keys.dart';
import 'core/common.dart';
import 'core/functions.dart';
import 'core/screens.dart';
import 'game/game_controller.dart';
import 'input/game_keys.dart';
import 'input/shortcuts.dart';
import 'main_controller.dart';
import 'scripting/game_script.dart';
import 'util/fonts.dart';

enum OptionsMenuEntry {
  full_random,
  rotate_can_move,
  rotate_clock_wise,
}

class OptionsScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, HasGameKeys {
  static OptionsMenuEntry? _rememberSelection;

  late final BasicMenuButton _random;
  late final BasicMenuButton _move;
  late final BasicMenuButton _clockwise;

  @override
  onLoad() async {
    fontSelect(menuFont, scale: 1);
    textXY('Main Menu', xCenter, lineHeight * 2, scale: 1.5);

    final buttonSheet = await sheetI('button_option.png', 1, 2);
    final menu = added(BasicMenu<OptionsMenuEntry>(buttonSheet, textFont, _selected));
    _random = menu.addEntry(OptionsMenuEntry.full_random, 'Full Random', anchor: Anchor.centerLeft);
    _move = menu.addEntry(OptionsMenuEntry.rotate_can_move, 'Rotate Can Move', anchor: Anchor.centerLeft);
    _clockwise = menu.addEntry(OptionsMenuEntry.rotate_clock_wise, 'Rotate Clockwise', anchor: Anchor.centerLeft);

    _random.checked = game_configuration.pure_random;
    _move.checked = game_configuration.rotate_can_move;
    _clockwise.checked = game_configuration.rotate_clock_wise;

    menu.position.setValues(xCenter, yCenter);
    menu.anchor = Anchor.center;

    _rememberSelection ??= menu.entries.first;

    menu.preselectEntry(_rememberSelection);
    menu.onPreselected = (it) => _rememberSelection = it;

    softkeys('Back', null, (_) => popScreen());
  }

  void _selected(OptionsMenuEntry it) {
    logInfo('Selected: $it');
    switch (it) {
      case OptionsMenuEntry.full_random:
        game_configuration.pure_random = !game_configuration.pure_random;
      case OptionsMenuEntry.rotate_can_move:
        game_configuration.rotate_can_move = !game_configuration.rotate_can_move;
      case OptionsMenuEntry.rotate_clock_wise:
        game_configuration.rotate_clock_wise = !game_configuration.rotate_clock_wise;
    }
    _random.checked = game_configuration.pure_random;
    _move.checked = game_configuration.rotate_can_move;
    _clockwise.checked = game_configuration.rotate_clock_wise;
  }
}
