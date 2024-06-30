import 'dart:convert';

import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
import 'package:jamjam24/game/hiscore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/soft_keys.dart';
import '../core/screens.dart';
import '../scripting/game_script.dart';
import '../util/on_message.dart';
import 'game_configuration.dart';
import 'game_model.dart';
import 'game_play_overlays.dart';
import 'game_play_screen.dart';
import 'keys.dart';
import 'sprite_drawer.dart';
import 'visual_configuration.dart';

export 'game_context.dart';

class GameController extends GameScriptComponent with HasVisibility {
  final configuration = GameConfiguration();
  final visual = VisualConfiguration();

  final keys = Keys();
  final model = GameModel();

  late final sprite_drawer = SpriteDrawer(visual);

  bool get show_empty_container => false;

  bool _loading = false;

  Future try_restore_state() async {
    try {
      _loading = true;

      final preferences = await SharedPreferences.getInstance();
      if (preferences.containsKey('game_state')) {
        final json = preferences.getString('game_state');
        if (json != null) {
          logVerbose(json);
          final data = jsonDecode(json);
          model.load_state(data);
          if (model.state != GameState.game_over) return;
        }
      }
      model.start_new_game();
    } catch (it, trace) {
      logError('Failed to restore game state: $it', trace);
    } finally {
      _loading = false;
    }
  }

  void try_store_state() async {
    try {
      if (_loading) return;

      final preferences = await SharedPreferences.getInstance();
      final json = jsonEncode(model.save_state({}));
      logVerbose(json);
      await preferences.setString('game_state', json);
    } catch (it, trace) {
      logError('Failed to store game state: $it', trace);
    }
  }

  void try_clear_state() async {
    logWarn('Clearing game state');
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove('game_state');
    } catch (it, trace) {
      logError('Failed to clear game state: $it', trace);
    }
  }

  // Component

  @override
  onLoad() async {
    await add(hiscore);
    await add(sprite_drawer);
    await add(GamePlayScreen());
    await add(keys);
    await add(model); // contains particles, which have to be drawn above the GamePlayScreen TODO revisit
    await add(GamePlayOverlays(_proceed));
  }

  @override
  void onMount() {
    super.onMount();
    onMessage<LevelComplete>((_) => try_store_state());
    onMessage<GameStateUpdate>((it) {
      logVerbose('game state update: ${it.state}');
      switch (it.state) {
        case GameState.game_paused:
        case GameState.confirm_exit:
          logVerbose('saving game state');
          try_store_state();
        case GameState.game_over:
          try_clear_state();
        case GameState.start_game:
        case GameState.playing_level:
          break;
      }
    });
  }

  @override
  void update(double dt) {
    if (!isVisible) return;
    super.update(dt);
    // TODO hook/callback instead of polling keys!
    switch (model.state) {
      // in these states, fire1 and fire2 act as confirm (soft key 2), too:
      case GameState.start_game:
      case GameState.game_paused:
        if (keys.check_and_consume(GameKey.soft1)) _proceed(SoftKey.left);
        if (keys.any([GameKey.fire1, GameKey.fire2, GameKey.soft2])) _proceed(SoftKey.right);

      // during game play only the explicit "soft keys" work for navigation:
      case GameState.playing_level:
      case GameState.confirm_exit:
      case GameState.game_over:
        if (keys.check_and_consume(GameKey.soft1)) _proceed(SoftKey.left);
        if (keys.check_and_consume(GameKey.soft2)) _proceed(SoftKey.right);
    }
  }

  @override
  void updateTree(double dt) {
    if (!isVisible) return;
    super.updateTree(dt);
  }

  // Implementation

  void _proceed(SoftKey it) {
    if (it == SoftKey.left) {
      switch (model.state) {
        case GameState.playing_level:
          model.confirm_exit();
        case GameState.game_over:
          if (model.is_new_hiscore() || model.is_ranked_score()) {
            showScreen(Screen.hiscore);
          } else {
            popScreen();
          }
        default:
          popScreen();
      }
    }
    if (it == SoftKey.right) {
      switch (model.state) {
        case GameState.start_game:
          model.start_playing();
        case GameState.game_paused:
          model.resume_game();
        case GameState.playing_level:
          model.pause_game();
        case GameState.game_over:
          if (model.is_new_hiscore() || model.is_ranked_score()) {
            showScreen(Screen.enter_hiscore);
          } else {
            model.start_new_game();
          }
        case GameState.confirm_exit:
          model.resume_game();
      }
    }
  }
}
