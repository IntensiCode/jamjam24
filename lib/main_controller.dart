import 'package:collection/collection.dart';
import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import 'audio_menu.dart';
import 'components/gradient_background.dart';
import 'core/common.dart';
import 'core/messaging.dart';
import 'core/screens.dart';
import 'enter_hiscore_screen.dart';
import 'game/game_controller.dart';
import 'game/game_model.dart';
import 'help_screen.dart';
import 'hiscore_screen.dart';
import 'loading_screen.dart';
import 'main_menu.dart';
import 'options_screen.dart';
import 'title_screen.dart';
import 'util/extensions.dart';
import 'web_play_screen.dart';

class MainController extends World with GameContext implements ScreenNavigation {
  final _stack = <Screen>[];

  final GameController _game = GameController()..isVisible = false;
  final GradientBackground _background = GradientBackground();

  @override
  GameController get game => _game;

  @override
  onLoad() async {
    messaging.listen<ShowScreen>((it) => showScreen(it.screen));
    await add(_background..opacity = 0);
    await add(_game);
  }

  @override
  void onMount() {
    if (debug) {
      _game.try_restore_state().then((_) => showScreen(Screen.title));
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
    logVerbose('pop screen with stack=$_stack and children=${children.map((it) => it.runtimeType)}');
    _stack.removeLastOrNull();
    showScreen(_stack.lastOrNull ?? Screen.title);
  }

  @override
  void pushScreen(Screen it) {
    logVerbose('push screen $it with stack=$_stack and children=${children.map((it) => it.runtimeType)}');
    if (_stack.lastOrNull == it) throw 'stack already contains $it';
    _stack.add(it);
    showScreen(it);
  }

  Screen? _triggered;

  @override
  void showScreen(Screen screen, {bool skip_fade_out = false, bool skip_fade_in = false}) {
    if (_triggered == screen) {
      logError('duplicate trigger ignored: $screen', StackTrace.current);
      return;
    }
    _triggered = screen;

    logVerbose('show $screen with $_stack and ${children.map((it) => it.runtimeType)} $skip_fade_out $skip_fade_in');

    _manage_background(screen);

    if (!skip_fade_out && children.length > 2) {
      children.last.fadeOutDeep(and_remove: true);
      children.last.removed.then((_) {
        if (_triggered == screen) {
          _triggered = null;
        } else if (_triggered != screen) {
          return;
        }
        showScreen(screen, skip_fade_in: skip_fade_in);
      });
    } else {
      final it = added(_makeScreen(screen));
      if (!skip_fade_in) it.mounted.then((_) => it.fadeInDeep());
    }
  }

  void _manage_background(Screen screen) {
    logVerbose('manage background for $screen');
    if (screen == Screen.loading || screen == Screen.game) {
      _background.fadeOutDeep(and_remove: false);
    } else {
      _background.fadeInDeep(restart: false);
    }
  }

  Component _makeScreen(Screen it) => switch (it) {
        Screen.audio_menu => AudioMenu(show_back: _stack.isNotEmpty),
        Screen.game => GameOn(_game),
        Screen.help => HelpScreen(),
        Screen.hiscore => HiscoreScreen(),
        Screen.enter_hiscore => EnterHiscoreScreen(),
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
    logVerbose(game.model.state);
  }

  @override
  void onRemove() => game.isVisible = false;
}
