import 'dart:convert';

import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
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

extension ComponentExtensions on Component {
  GameConfiguration get configuration => findParent<GameController>(includeSelf: true)!.configuration;

  VisualConfiguration get visual => findParent<GameController>(includeSelf: true)!.visual;

  Keys get keys => findParent<GameController>(includeSelf: true)!.keys;

  GameModel get model => findParent<GameController>(includeSelf: true)!.model;

  SpriteDrawer get sprite_drawer => findParent<GameController>(includeSelf: true)!.sprite_drawer;

  bool get show_empty_container => findParent<GameController>(includeSelf: true)!.show_empty_container;
}

class GameController extends GameScriptComponent with HasVisibility {
  final configuration = GameConfiguration();
  final visual = VisualConfiguration();

  final keys = Keys();
  final model = GameModel();

  late final sprite_drawer = SpriteDrawer(visual);

  bool get show_empty_container => false;

  Future try_restore_state() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (preferences.containsKey('game_state')) {
        final json = preferences.getString('game_state');
        if (json != null) {
          logInfo(json);
          final data = jsonDecode(json);
          model.load_state(data);
          if (model.state != GameState.game_over) return;
        }
      }
      model.start_new_game();
    } catch (it, trace) {
      logError('Failed to restore game state: $it', trace);
      // try_clear_state();
    }
  }

  void try_store_state() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final json = jsonEncode(model.save_state({}));
      logInfo(json);
      await preferences.setString('game_state', json);
    } catch (it, trace) {
      logError('Failed to store game state: $it', trace);
    }
  }

  void try_clear_state() async {
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
    await add(sprite_drawer);
    await add(GamePlayScreen());
    await add(keys);
    await add(model); // contains particles, which have to be drawn above the GamePlayScreen TODO revisit
    await add(GamePlayOverlays(_proceed));
  }

  @override
  void onMount() {
    super.onMount();
    onMessage<GameStateUpdate>((it) {
      switch (it.state) {
        case GameState.game_paused:
        case GameState.level_complete:
        case GameState.confirm_exit:
          try_store_state();
        case GameState.game_over:
          try_clear_state();
        case GameState.start_game:
        case GameState.level_info:
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
      case GameState.level_info:
      case GameState.game_paused:
      case GameState.level_complete:
        if (keys.check_and_consume(GameKey.soft1)) _proceed(SoftKey.left);
        if (keys.any([GameKey.fire1, GameKey.fire2, GameKey.soft2])) _proceed(SoftKey.right);

      // during game play only the explicit "soft keys" work for navigation:
      case GameState.playing_level:
      case GameState.game_over:
      case GameState.confirm_exit:
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
        default:
          popScreen();
      }
    }
    if (it == SoftKey.right) {
      switch (model.state) {
        case GameState.start_game:
          model.start_playing();
        case GameState.level_info:
          model.start_playing();
        case GameState.game_paused:
          model.resume_game();
        case GameState.level_complete:
          model.advance_level();
        case GameState.playing_level:
          model.pause_game();
        case GameState.game_over:
          model.start_new_game();
        case GameState.confirm_exit:
          model.resume_game();
      }
    }
  }
}

//     private int myGameOverWaitTicks = 0;
//
//     private void onGameOver() throws Exception
//         {
//         if ( !isVisible( myLevelStatusScreen ) )
//             {
//             system().hooks.trackState( "game", "state", "game over" );
//
//             gameModel().endOfGame();
//             myGameOverWaitTicks = timing().ticksPerSecond / 2;
//             }
//
//         //#if ONLINE
//         onSubmitScore();
//         //#else
//         if ( myGameModel.isNewHiscore() || myGameModel.isRankedScore() )
//             {
//             onRankedScore();
//             }
//         else
//             {
//             mySoftkeys.setSoftkeys( I18n._( "END" ), I18n._( "END" ) );
//
//             //#if ADS
//             if ( !isVisible( myLevelStatusScreen ) ) system().hooks.triggerNewFullscreenAd();
//             //#endif
//
//             setVisibility( myEndGameAlert, false );
//             setVisibility( myLevelStatusScreen, true );
//
//             if ( myGameOverWaitTicks > 0 )
//                 {
//                 myGameOverWaitTicks--;
//                 return;
//                 }
//
//             final KeysHandler keys = keys();
//             final boolean leftOrRightSoft = keys.checkLeftSoftAndConsume() || keys.checkRightSoftAndConsume();
//             final boolean stickDownOrFire = keys.checkStickDownAndConsume() || keys.checkFireAndConsume();
//             if ( leftOrRightSoft || stickDownOrFire )
//                 {
//                 //#if RELEASE
//                 storage().erase( myGameModel );
//                 //#endif
//                 stack().popScreen( this );
//                 }
//             }
//         //#endif
//         }
//
//     private void onSubmitScore() throws Exception
//         {
//         mySoftkeys.setSoftkeys( I18n._( "CONTINUE" ), I18n._( "SKIP" ) );
//
//         setVisibility( myEndGameAlert, false );
//         setVisibility( myLevelStatusScreen, true );
//
//         if ( myGameOverWaitTicks > 0 )
//             {
//             myGameOverWaitTicks--;
//             return;
//             }
//
//         final KeysHandler keys = keys();
//         final boolean stickDownOrFire = keys.checkStickDownAndConsume() || keys.checkFireAndConsume();
//         if ( keys.checkLeftSoftAndConsume() || stickDownOrFire )
//             {
//             //#if RELEASE
//             storage().erase( myGameModel );
//             //#endif
//             stack().popScreen( this );
//             myMainLogic.enterHiscore();
//             }
//         else if ( keys.checkRightSoftAndConsume() )
//             {
//             //#if RELEASE
//             storage().erase( myGameModel );
//             //#endif
//             stack().popScreen( this );
//             }
//         }
//
//     private void onRankedScore() throws Exception
//         {
//         mySoftkeys.setSoftkeys( I18n._( "CONTINUE" ), I18n._( "CONTINUE" ) );
//
//         setVisibility( myEndGameAlert, false );
//         setVisibility( myLevelStatusScreen, true );
//
//         if ( myGameOverWaitTicks > 0 )
//             {
//             myGameOverWaitTicks--;
//             return;
//             }
//
//         final KeysHandler keys = keys();
//         final boolean leftOrRightSoft = keys.checkLeftSoftAndConsume() || keys.checkRightSoftAndConsume();
//         final boolean stickDownOrFire = keys.checkStickDownAndConsume() || keys.checkFireAndConsume();
//         if ( leftOrRightSoft || stickDownOrFire )
//             {
//             //#if RELEASE
//             storage().erase( myGameModel );
//             //#endif
//             stack().popScreen( this );
//             myMainLogic.enterHiscore();
//             }
//         }
