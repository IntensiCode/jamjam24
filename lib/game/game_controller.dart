import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';

import '../core/screens.dart';
import '../scripting/game_script.dart';
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

class GameController extends GameScriptComponent {
  final configuration = GameConfiguration();
  final visual = VisualConfiguration();

  final keys = Keys();
  final model = GameModel();

  late final sprite_drawer = SpriteDrawer(visual);

  bool get show_empty_container => false;

  // Component

  @override
  onLoad() async {
    add(sprite_drawer);
    add(GamePlayScreen());
    add(keys);
    add(model); // contains particles, which have to be drawn above the GamePlayScreen TODO revisit
    add(GamePlayOverlays());
  }

  @override
  void onMount() {
    super.onMount();
    // TODO how to do this? start vs resume? where? and how?
    model.start_new_game();
  }

  @override
  void onRemove() {
    logInfo(model.save_state({}));
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (model.state) {
      case GameState.start_game:
        if (keys.check_and_consume(GameKey.soft1)) popScreen();
        if (keys.any([GameKey.fire1, GameKey.fire2, GameKey.soft2])) model.start_playing();
        break;
      case GameState.level_info:
      case GameState.game_paused:
        if (keys.check_and_consume(GameKey.soft1)) popScreen();
        if (keys.any([GameKey.fire1, GameKey.fire2, GameKey.soft2])) model.resume_game();
        break;
      case GameState.level_complete:
        if (keys.check_and_consume(GameKey.soft1)) popScreen();
        if (keys.any([GameKey.fire1, GameKey.fire2, GameKey.soft2])) model.advance_level();
        break;
      case GameState.playing_level:
        if (keys.check_and_consume(GameKey.soft1)) model.confirm_exit();
        if (keys.check_and_consume(GameKey.soft2)) model.pause_game();
        break;
      case GameState.game_over:
        if (keys.check_and_consume(GameKey.soft1)) popScreen();
        if (keys.check_and_consume(GameKey.soft2)) model.start_new_game();
        break;
      case GameState.confirm_exit:
        if (keys.check_and_consume(GameKey.soft1)) popScreen();
        if (keys.check_and_consume(GameKey.soft2)) model.resume_game();
        break;
    }
  }

  // Implementation

  void todo() {}
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
