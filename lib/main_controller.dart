import 'package:collection/collection.dart';
import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import 'audio_menu.dart';
import 'components/gradient_background.dart';
import 'core/messaging.dart';
import 'core/screens.dart';
import 'game/game_controller.dart';
import 'help_screen.dart';
import 'hiscore_screen.dart';
import 'loading_screen.dart';
import 'main_menu.dart';
import 'options_screen.dart';
import 'title_screen.dart';
import 'util/extensions.dart';

class MainController extends World implements ScreenNavigation {
  final _stack = <Screen>[];

  GradientBackground? _background;

  @override
  void onMount() => messaging.listen<ShowScreen>((it) => showScreen(it.screen));

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
    logInfo(
        'showScreen $screen with $_stack and ${children.map((it) => it.runtimeType)} (out? $skip_fade_out in? $skip_fade_in)');

    _manage_background(screen);

    if (!skip_fade_out && children.length > 1) {
      children.last.fadeOutDeep(and_remove: true);
      children.last.removed.then((_) => showScreen(screen, skip_fade_in: skip_fade_in));
    } else {
      removeAll(children.whereNot((it) => it is GradientBackground));
      final it = added(_makeScreen(screen));
      if (!skip_fade_in) it.mounted.then((_) => it.fadeInDeep());
    }
  }

  void _manage_background(Screen screen) {
    if (screen == Screen.loading || screen == Screen.game) {
      _background?.fadeOutDeep();
      _background = null;
    } else {
      _background ??= added(GradientBackground()..opacity = 0);
      _background?.fadeInDeep(restart: false);
    }
  }

  Component _makeScreen(Screen it) => switch (it) {
        Screen.audio_menu => AudioMenu(show_back: _stack.isNotEmpty),
        Screen.controls => throw 'not implemented: $it',
        Screen.game => GameController(),
        Screen.help => HelpScreen(),
        Screen.hiscore => HiscoreScreen(),
        Screen.keys => throw 'not implemented: $it',
        Screen.loading => LoadingScreen(),
        Screen.main_menu => MainMenu(),
        Screen.options => OptionsScreen(),
        Screen.title => TitleScreen(),
      };
}
