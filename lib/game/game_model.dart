import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/messaging.dart';
import 'block_container.dart';
import 'clear_all.dart';
import 'detonating_blocks.dart';
import 'dropped_tiles.dart';
import 'exploding_blocks.dart';
import 'exploding_lines.dart';
import 'explosions.dart';
import 'extras.dart';
import 'game_controller.dart';
import 'game_object.dart';
import 'hiscore.dart';
import 'level.dart';
import 'player.dart';
import 'pop_up_letters.dart';
import 'smoke.dart';

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
  level_info,
  playing_level,
  game_paused,
  game_over,
  level_complete,
  confirm_exit,
  ;

  static GameState from(final String name) => GameState.values.firstWhere((e) => e.toString() == name);
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

  set state(GameState value) {
    logInfo('set state to $value');
    _state = value;
    sendMessage(GameStateUpdate(value));
  }

  @override
  onLoad() {
    position.setFrom(visual.container_position);
    add(container = BlockContainer());
    add(level = Level());
    add(clear_all = ClearAll());
    add(detonating_blocks = DetonatingBlocks());
    add(exploding_lines = ExplodingLines());
    add(exploding_blocks = ExplodingBlocks());
    add(dropped_tiles = DroppedTiles());
    add(player = Player());
    add(letters = PopUpLetters());
    add(extras = Extras());
    add(smoke = SmokeParticles());
    add(explosions = Explosions());
  }

  bool is_new_hiscore() => hiscore.isNewHiscore(player.score);

  bool is_ranked_score() => hiscore.isHiscoreRank(player.score);

  void trigger_clear_all() => clear_all.trigger();

  void start_new_game() {
    logInfo('start_new_game');
    propagateToChildren((it) {
      if (it case GameObject go) go.on_start_new_game();
      return true;
    });
    state = GameState.start_game;
  }

  void start_playing() {
    logInfo('start_level');
    propagateToChildren((it) {
      if (it case GameObject go) go.on_start_playing();
      return true;
    });
    state = GameState.playing_level;
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
  }

  void advance_level() {
    logInfo('advance_level');
    level.advance();
    state = GameState.level_info;
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
    state = GameState.from(data['state']);
    propagateToChildren((it) {
      if (it case GameObject go) {
        logInfo('load state of ${go.runtimeType}');
        go.load_state(data[it.runtimeType.toString()]);
      }
      return true;
    });
  }

  @override
  GameData save_state(GameData data) {
    data['state'] = state.name;
    propagateToChildren((it) {
      if (it case GameObject go) {
        logInfo('save state of ${go.runtimeType}');
        if (data.containsKey(it.runtimeType.toString())) throw '$it already taken';
        data[it.runtimeType.toString()] = go.save_state({});
      }
      return true;
    });
    return data;
  }

  // Component

  @override
  void updateTree(double dt) {
    if (state == GameState.confirm_exit) return;
    if (state == GameState.game_paused) return;
    super.updateTree(dt);
    if (player.is_blocked) state = GameState.game_over;
    if (level.is_complete) state = GameState.level_complete;
  }
}
