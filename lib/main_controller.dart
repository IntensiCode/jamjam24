import 'package:collection/collection.dart';
import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:jamjam24/game/game_model.dart';

import 'audio_menu.dart';
import 'components/gradient_background.dart';
import 'core/common.dart';
import 'core/messaging.dart';
import 'core/screens.dart';
import 'game/game_configuration.dart';
import 'game/game_controller.dart';
import 'help_screen.dart';
import 'hiscore_screen.dart';
import 'loading_screen.dart';
import 'main_menu.dart';
import 'options_screen.dart';
import 'title_screen.dart';
import 'util/extensions.dart';
import 'web_play_screen.dart';

extension ComponentExtension on Component {
  GameConfiguration get game_configuration => findParent<MainController>(includeSelf: true)!._game.configuration;

  bool can_resume_game() => findParent<MainController>(includeSelf: true)!._game.model.is_new_game == false;

  void clear_game_state() => findParent<MainController>(includeSelf: true)!._game.model.start_new_game();
}

class MainController extends World implements ScreenNavigation {
  final _stack = <Screen>[];

  final GameController _game = GameController()..isVisible = false;
  final GradientBackground _background = GradientBackground();

  @override
  onLoad() async {
    messaging.listen<ShowScreen>((it) => showScreen(it.screen));
    await add(_background..opacity = 0);
    await add(_game);
  }

  @override
  void onMount() {
    if (debug) {
      _game.try_restore_state().then((_) => showScreen(Screen.game));
    } else {
      _game.try_restore_state();
      if (kIsWeb) {
        add(WebPlayScreen());
      } else {
        add(LoadingScreen());
      }
    }
  }

  @override
  void popScreen() {
    logInfo('pop screen with stack=$_stack and children=${children.map((it) => it.runtimeType)}');
    _stack.removeLastOrNull();
    showScreen(_stack.lastOrNull ?? Screen.title);
  }

  @override
  void pushScreen(Screen it) {
    logInfo('push screen $it with stack=$_stack and children=${children.map((it) => it.runtimeType)}');
    if (_stack.lastOrNull == it) throw 'stack already contains $it';
    _stack.add(it);
    showScreen(it);
  }

  @override
  void showScreen(Screen screen, {bool skip_fade_out = false, bool skip_fade_in = false}) {
    logInfo('show $screen with $_stack and ${children.map((it) => it.runtimeType)} $skip_fade_out $skip_fade_in');

    _manage_background(screen);

    if (!skip_fade_out && children.length > 2) {
      children.last.fadeOutDeep(and_remove: true);
      children.last.removed.then((_) => showScreen(screen, skip_fade_in: skip_fade_in));
    } else {
      final it = added(_makeScreen(screen));
      if (!skip_fade_in) it.mounted.then((_) => it.fadeInDeep());
    }
  }

  void _manage_background(Screen screen) {
    logInfo('manage background for $screen');
    if (screen == Screen.loading || screen == Screen.game) {
      _background.fadeOutDeep(and_remove: false);
    } else {
      _background.fadeInDeep(restart: false);
    }
  }

  Component _makeScreen(Screen it) => switch (it) {
        Screen.audio_menu => AudioMenu(show_back: _stack.isNotEmpty),
        Screen.controls => throw 'not implemented: $it',
        Screen.game => GameOn(_game),
        Screen.help => HelpScreen(),
        Screen.hiscore => HiscoreScreen(),
        Screen.keys => throw 'not implemented: $it',
        Screen.loading => LoadingScreen(),
        Screen.main_menu => MainMenu(),
        Screen.options => OptionsScreen(),
        Screen.title => TitleScreen(),
      };
}

class GameOn extends Component {
  GameOn(this.game);

  final GameController game;

  @override
  void onMount() {
    if (game.model.state == GameState.confirm_exit) {
      game.model.pause_game();
    }
    game.isVisible = true;
    logInfo(game.model.state);
  }

  @override
  void onRemove() => game.isVisible = false;
}
