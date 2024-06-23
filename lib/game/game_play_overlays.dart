import '../components/soft_keys.dart';
import '../core/screens.dart';
import '../scripting/game_script.dart';
import '../util/on_message.dart';
import 'confirm_exit.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_paused.dart';
import 'level_info.dart';
import 'level_status.dart';

class GamePlayOverlays extends GameScriptComponent {
  @override
  onLoad() {
    super.onLoad();
    onMessage<GameStateUpdate>(_on_game_state);
  }

  @override
  void onMount() {
    super.onMount();
    onMessage<GameStateUpdate>(_on_game_state);
  }

  void _on_game_state(GameStateUpdate it) {
    switch (it.state) {
      case GameState.start_game:
        _on_start_new_game();
      case GameState.level_info:
        _on_level_info();
      case GameState.playing_level:
        _on_playing_game();
      case GameState.game_paused:
        _on_pause_game();
      case GameState.level_complete:
        _on_level_complete();
      case GameState.game_over:
        _on_game_over();
      case GameState.confirm_exit:
        _on_confirm_exit();
    }
  }

  void _on_start_new_game() {
    removeAll(children);
    add(LevelInfo());
    softkeys('Back', 'Start', (it) {
      if (it == SoftKey.left) popScreen();
      if (it == SoftKey.right) model.start_playing();
    }, shortcuts: false);
  }

  void _on_level_info() {
    removeAll(children);
    add(LevelInfo());
    softkeys('Menu', 'Continue', (it) {
      if (it == SoftKey.left) popScreen();
      if (it == SoftKey.right) model.resume_game();
    }, shortcuts: false);
  }

  void _on_playing_game() {
    removeAll(children);
    softkeys('Menu', 'Pause', (it) {
      if (it == SoftKey.left) model.confirm_exit();
      if (it == SoftKey.right) model.pause_game();
    }, shortcuts: false);
  }

  void _on_pause_game() {
    removeAll(children);
    add(GamePaused());
    softkeys('Menu', 'Continue', (it) {
      if (it == SoftKey.left) popScreen();
      if (it == SoftKey.right) model.resume_game();
    }, shortcuts: false);
  }

  void _on_level_complete() {
    removeAll(children);
    add(LevelStatus());
    softkeys('Menu', 'Continue', (it) {
      if (it == SoftKey.left) popScreen();
      if (it == SoftKey.right) model.advance_level();
    }, shortcuts: false);
  }

  void _on_game_over() {
    removeAll(children);
    add(LevelStatus());
    softkeys('Menu', 'New Game', (it) {
      if (it == SoftKey.left) popScreen();
      if (it == SoftKey.right) model.resume_game();
    }, shortcuts: false);
  }

  void _on_confirm_exit() {
    removeAll(children);
    add(ConfirmExit());
    softkeys('Yes', 'No', (it) {
      if (it == SoftKey.left) popScreen();
      if (it == SoftKey.right) model.resume_game();
    }, shortcuts: false);
  }
}
