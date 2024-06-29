import 'package:flame/components.dart';

import 'game_configuration.dart';
import 'game_controller.dart';
import 'game_model.dart';
import 'keys.dart';
import 'sprite_drawer.dart';
import 'visual_configuration.dart';

mixin GameContext on Component {
  GameController get game;
}

extension ComponentExtensions on Component {
  GameController get game => findParent<GameContext>(includeSelf: true)!.game;

  GameConfiguration get configuration => game.configuration;

  VisualConfiguration get visual => game.visual;

  Keys get keys => game.keys;

  GameModel get model => game.model;

  SpriteDrawer get sprite_drawer => game.sprite_drawer;

  bool get show_empty_container => game.show_empty_container;

  bool get can_resume_game => game.model.is_new_game == false;

  void clear_game_state() => game.model.start_new_game();
}
