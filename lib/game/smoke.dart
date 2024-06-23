import 'dart:ui';

import '../core/common.dart';
import '../core/random.dart';
import '../util/extensions.dart';
import 'game_controller.dart';
import 'game_object.dart';
import 'game_particles.dart';
import 'placed_tile.dart';

class SmokeParticles extends GameParticles<Smoke> {
  SmokeParticles() : super(Smoke.new);

  void spawn_for(PlacedTile aTile) {
    final int x = aTile.pos_x;
    final int y = aTile.pos_y;
    final width = aTile.width * 3 / 4;
    final height = aTile.height * 2 / 3;
    final int count = configuration.detonate_particles;
    for (int idx = 0; idx < count; idx++) {
      final tickOffset = tps * idx / count / 4;
      final tickDelay = rng.nextDoubleLimit(tps / 3);
      final xOffset = rng.nextDoublePM(width / 2);
      final yOffset = rng.nextDoublePM(height / 2);
      final xPos = x + 1 + (xOffset * 3 / 2);
      final yPos = y + 1 + (yOffset * 3 / 2);
      require_particle()
        ..init_position(xPos, yPos)
        ..init_timing((tickOffset + tickDelay).toInt(), (tps / 2 - tickDelay).toInt())
        ..activate();
    }
  }

  void spawn_at(double x, double y) => require_particle()
    ..init_position(x, y)
    ..init_timing(0, tps)
    ..activate();

  @override
  void render(Canvas canvas) {
    for (final it in active_particles) {
      sprite_drawer.draw_smoke_at(canvas, it.x, it.y, it.progress);
    }
  }
}

class Smoke with HasGameData, GameParticle, ManagedGameParticle {
  @override
  bool get loop => false;

  @override
  void update_while_active() => y -= 4.0 / tps;
}
