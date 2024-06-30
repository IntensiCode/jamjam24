import 'package:dart_minilog/dart_minilog.dart';

import '../components/soft_keys.dart';
import '../scripting/game_script.dart';
import '../util/on_message.dart';
import 'confirm_exit.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'game_paused.dart';
import 'level_info.dart';
import 'level_status.dart';

class GamePlayOverlays extends GameScriptComponent {
  GamePlayOverlays(this._proceed);

  final void Function(SoftKey) _proceed;

  @override
  onLoad() {
    super.onLoad();
    onMessage<GameStateUpdate>((it) => _on_game_state(it.state));
    _on_game_state(model.state);

    onMessage<LevelComplete>((_) => _on_level_info());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (model.state != seen) _on_game_state(model.state);
  }

  GameState? seen;

  void _on_game_state(GameState it) {
    seen = it;
    logVerbose('on_game_state: $it');
    switch (it) {
      case GameState.start_game:
        _on_start_new_game();
      case GameState.playing_level:
        _on_playing_game();
      case GameState.game_paused:
        _on_pause_game();
      case GameState.game_over:
        if (model.is_ranked_score()) {
          _on_hiscore();
        } else {
          _on_game_over();
        }
      case GameState.confirm_exit:
        _on_confirm_exit();
    }
  }

  void _on_start_new_game() {
    removeAll(children);
    add(LevelInfo());
    softkeys('Back', 'Start', _proceed, shortcuts: false);
  }

  void _on_level_info() {
    removeAll(children);
    add(LevelInfo());
  }

  void _on_playing_game() {
    removeAll(children);
    softkeys('Menu', 'Pause', _proceed, shortcuts: false);
  }

  void _on_pause_game() {
    removeAll(children);
    add(GamePaused());
    softkeys('Menu', 'Continue', _proceed, shortcuts: false);
  }

  void _on_game_over() {
    removeAll(children);
    add(GameResult(_proceed));
    softkeys('Menu', 'New Game', _proceed, shortcuts: false);
  }

  void _on_hiscore() {
    removeAll(children);
    add(GameResult(_proceed));
    softkeys('Continue', 'Continue', _proceed, shortcuts: false);
  }

  void _on_confirm_exit() {
    removeAll(children);
    add(ConfirmExit());
    softkeys('Yes', 'No', _proceed, shortcuts: false);
  }
}
