import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/messaging.dart';
import '../core/soundboard.dart';
import 'block_container.dart';
import 'clear_all.dart';
import 'detonating_blocks.dart';
import 'dropped_tiles.dart';
import 'exploding_blocks.dart';
import 'exploding_lines.dart';
import 'explosions.dart';
import 'extras.dart';
import 'game_context.dart';
import 'game_object.dart';
import 'hiscore.dart';
import 'level.dart';
import 'player.dart';
import 'pop_up_letters.dart';
import 'smoke.dart';

class LevelComplete with Message {}

extension ComponentExtensions on Component {
  BlockContainer get container => model.container;

  Level get level => model.level;

  Player get player => model.player;

  Explosions get explosions => model.explosions;

  ExplodingLines get exploding_lines => model.exploding_lines;

  ExplodingBlocks get exploding_blocks => model.exploding_blocks;

  DetonatingBlocks get detonating_blocks => model.detonating_blocks;

  DroppedTiles get dropped_tiles => model.dropped_tiles;

  SmokeParticles get smoke => model.smoke;

  PopUpLetters get letters => model.letters;

  Extras get extras => model.extras;

  ClearAll get clear_all => model.clear_all;
}

enum GameState {
  start_game,
  playing_level,
  game_paused,
  game_over,
  confirm_exit,
  ;

  static GameState from(final String name) => GameState.values.firstWhere((e) => e.name == name);
}

class GameStateUpdate with Message {
  final GameState state;

  GameStateUpdate(this.state);
}

class GameModel extends PositionComponent with HasGameData {
  late final BlockContainer container;
  late final Level level;
  late final Player player;
  late final Explosions explosions;
  late final DetonatingBlocks detonating_blocks;
  late final ExplodingBlocks exploding_blocks;
  late final ExplodingLines exploding_lines;
  late final DroppedTiles dropped_tiles;
  late final SmokeParticles smoke;
  late final PopUpLetters letters;
  late final Extras extras;
  late final ClearAll clear_all;

  GameState _state = GameState.start_game;

  GameState get state => _state;

  bool is_new_game = true;

  set state(GameState value) {
    logVerbose('set state to $value');
    _state = value;
    sendMessage(GameStateUpdate(value));
  }

  @override
  onLoad() async {
    position.setFrom(visual.container_position);
    await add(container = BlockContainer());
    await add(level = Level());
    await add(clear_all = ClearAll());
    await add(detonating_blocks = DetonatingBlocks());
    await add(exploding_lines = ExplodingLines());
    await add(exploding_blocks = ExplodingBlocks());
    await add(dropped_tiles = DroppedTiles());
    await add(player = Player());
    await add(letters = PopUpLetters());
    await add(extras = Extras());
    await add(smoke = SmokeParticles());
    await add(explosions = Explosions());
  }

  bool is_new_hiscore() => hiscore.isNewHiscore(player.score);

  bool is_ranked_score() => hiscore.isHiscoreRank(player.score);

  void trigger_clear_all() => clear_all.trigger();

  void start_new_game() {
    logInfo('start_new_game');
    is_new_game = true;
    propagateToChildren((it) {
      if (it case GameObject go) go.on_start_new_game();
      return true;
    });
    state = GameState.start_game;
  }

  void start_playing() {
    logInfo('start_playing');
    state = GameState.playing_level;
    is_new_game = false;

    propagateToChildren((it) {
      if (it case GameObject go) go.on_start_playing();
      return true;
    });
  }

  void confirm_exit() {
    logInfo('confirm_exit');
    state = GameState.confirm_exit;
  }

  void pause_game() {
    logInfo('pause_game');
    state = GameState.game_paused;
  }

  void resume_game() {
    logInfo('resume_game');
    state = GameState.playing_level;
    logInfo(player.state);
    propagateToChildren((it) {
      if (it case GameObject go) go.on_resume_game();
      return true;
    });
    is_new_game = false;
  }

  void on_end_of_level() {
    logInfo('on_end_of_level');
    propagateToChildren((it) {
      if (it case GameObject go) go.on_end_of_level();
      return true;
    });
  }

  void on_end_of_game() {
    logInfo('on_end_of_game');
    propagateToChildren((it) {
      if (it case GameObject go) go.on_end_of_game();
      return true;
    });
  }

  // HasGameData

  @override
  void load_state(GameData data) {
    final update = _state = GameState.from(data['state']);
    propagateToChildren((it) {
      if (it case GameObject go) {
        go.load_state(data[it.runtimeType.toString()]);
      }
      return true;
    });
    is_new_game = false;
    state = update;
    logInfo('game state loaded');
  }

  @override
  GameData save_state(GameData data) {
    logInfo('save game state: $_state');
    data['state'] = GameState.game_paused.name;
    propagateToChildren((it) {
      if (it case GameObject go) {
        if (data.containsKey(it.runtimeType.toString())) throw '$it already taken';
        data[it.runtimeType.toString()] = go.save_state({});
      }
      return true;
    });
    logInfo('game state saved');
    return data;
  }

  // Component

  @override
  void updateTree(double dt) {
    if (state == GameState.confirm_exit) return;
    if (state == GameState.game_paused) return;
    if (state == GameState.game_over) return;

    super.updateTree(dt);

    if (player.is_blocked) {
      is_new_game = true;
      state = GameState.game_over;
      if (is_new_hiscore() || is_ranked_score()) {
        soundboard.play(Sound.hiscore);
      }
    } else if (level.is_complete) {
      _advance_level();
      sendMessage(LevelComplete());
    }
  }

  void _advance_level() {
    logInfo('advance_level');
    level.advance();
    soundboard.play(Sound.level_complete);
    is_new_game = false;
  }
}
