import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
import 'package:jamjam24/game/game_configuration.dart';

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
import 'scripting/game_script.dart';
import 'util/fonts.dart';

enum OptionsMenuEntry {
  drop_hint,
  full_random,
  rotate_can_move,
  rotate_clock_wise,
}

class OptionsScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, HasGameKeys {
  static OptionsMenuEntry? _rememberSelection;

  late final BasicMenuButton _drop_hint;
  late final BasicMenuButton _random;
  late final BasicMenuButton _move;
  late final BasicMenuButton _clockwise;

  @override
  onLoad() async {
    fontSelect(menuFont, scale: 1);
    textXY('Main Menu', xCenter, lineHeight * 2, scale: 1.5);

    final buttonSheet = await sheetI('button_option.png', 1, 2);
    final menu = added(BasicMenu<OptionsMenuEntry>(buttonSheet, textFont, _selected));
    _drop_hint = menu.addEntry(OptionsMenuEntry.drop_hint, 'Drop Hint', anchor: Anchor.centerLeft);
    _random = menu.addEntry(OptionsMenuEntry.full_random, 'Full Random', anchor: Anchor.centerLeft);
    _move = menu.addEntry(OptionsMenuEntry.rotate_can_move, 'Rotate Can Move', anchor: Anchor.centerLeft);
    _clockwise = menu.addEntry(OptionsMenuEntry.rotate_clock_wise, 'Rotate Clockwise', anchor: Anchor.centerLeft);

    _drop_hint.checked = configuration.drop_hint_mode != DropHint.never;
    _random.checked = configuration.pure_random;
    _move.checked = configuration.rotate_can_move;
    _clockwise.checked = configuration.rotate_clock_wise;

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
      case OptionsMenuEntry.drop_hint:
        configuration.drop_hint_mode = switch (configuration.drop_hint_mode) {
          DropHint.never => DropHint.always,
          DropHint.always => DropHint.never,
          _ => DropHint.always,
        };
      case OptionsMenuEntry.full_random:
        configuration.pure_random = !configuration.pure_random;
      case OptionsMenuEntry.rotate_can_move:
        configuration.rotate_can_move = !configuration.rotate_can_move;
      case OptionsMenuEntry.rotate_clock_wise:
        configuration.rotate_clock_wise = !configuration.rotate_clock_wise;
    }
    _drop_hint.checked = configuration.drop_hint_mode != DropHint.never;
    _random.checked = configuration.pure_random;
    _move.checked = configuration.rotate_can_move;
    _clockwise.checked = configuration.rotate_clock_wise;
  }
}
