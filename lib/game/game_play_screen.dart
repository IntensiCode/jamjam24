import 'package:flame/components.dart';

import 'block_container_drawer.dart';
import 'column_bubbles.dart';
import 'game_controller.dart';
import 'player_drawer.dart';
import 'scoreboard.dart';
import 'touch_buttons.dart';

class GamePlayScreen extends Component {
  @override
  onLoad() {
    add(ColumnBubbles());
    add(Scoreboard());
    if (visual.touch_buttons) add(TouchButtons());
    add(GameDrawer());
  }
}

class GameDrawer extends PositionComponent {
  @override
  onLoad() {
    position.setFrom(visual.container_position);
    add(BlockContainerDrawer());
    add(PlayerDrawer());
  }
}
