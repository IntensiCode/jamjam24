import 'package:flame/components.dart';

import 'block_container_drawer.dart';
import 'column_bubbles.dart';
import 'game_controller.dart';
import 'player_drawer.dart';
import 'scoreboard.dart';
import 'touch_buttons.dart';

class GamePlayScreen extends Component {
  @override
  onLoad() async {
    await add(ColumnBubbles());
    await add(Scoreboard());
    if (visual.touch_buttons) await add(TouchButtons());
    await add(GameDrawer());
  }
}

class GameDrawer extends PositionComponent {
  @override
  onLoad() async {
    position.setFrom(visual.container_position);
    await add(BlockContainerDrawer());
    await add(PlayerDrawer());
  }
}
