import 'package:collection/collection.dart';
import 'package:flame/components.dart';

import '../util/auto_dispose.dart';
import '../util/extensions.dart';
import 'game_object.dart';

abstract class GameParticles<T extends GameParticle> extends Component with AutoDispose, GameObject {
  GameParticles(this._new);

  final T Function() _new;

  final particles = <T>[];

  Iterable<T> get active_particles => particles.where((it) => it.active);

  int active_particles_count() => active_particles.length;

  T require_particle() => (_reuse() ?? _added(_new()))..reset();

  T? _reuse() => particles.firstWhereOrNull((it) => !it.active);

  T _added(T it) {
    particles.add(it);
    return it;
  }

  bool get is_active => particles.any((it) => it.active);

  // Component

  @override
  void update(double dt) {
    for (final it in active_particles.whereType<ManagedGameParticle>()) {
      it.update(dt);
    }
  }

  // GameObject

  @override
  void on_start_new_game() => particles.clear();

  // HasGameData

  @override
  void load_state(GameData data) {
    particles.clear();
    for (final it in data['particles']) {
      require_particle().load_state(it);
    }
  }

  @override
  GameData save_state(GameData data) =>
      data..['particles'] = particles.where((it) => it.active).mapList((it) => it.save_state({}));
}

mixin ManagedGameParticle on GameParticle {
  abstract final bool loop;

  int tick_counter = 0;
  int tick_duration = 0;
  int tick_delay = 0;
  double x = 0;
  double y = 0;

  double get progress => (tick_counter / tick_duration).clamp(0, 1);

  @override
  void reset() {
    super.reset();
    tick_counter = tick_duration = tick_delay = 0;
    x = y = 0;
  }

  void init_position(final double x, final double y) {
    this.x = x;
    this.y = y;
  }

  void init_timing(final int tick_delay, final int tick_duration) {
    this.tick_delay = tick_delay;
    this.tick_duration = tick_duration;
  }

  void update(double dt) {
    if (active && tick_delay == 0) update_while_active();

    if (!active) {
      return;
    } else if (tick_delay > 0) {
      tick_delay--;
    } else if (tick_counter < tick_duration) {
      tick_counter++;
    } else if (loop) {
      tick_counter = 0;
    } else {
      on_completed();
      active = false;
    }
  }

  void update_while_active();

  void on_completed() {}

  // HasGameData

  @override
  void load_state(GameData data) {
    super.load_state(data);
    tick_counter = data['tick_counter'];
    tick_duration = data['tick_duration'];
    tick_delay = data['tick_delay'];
    x = data['x'];
    y = data['y'];
  }

  @override
  GameData save_state(GameData data) => super.save_state(data
    ..['tick_counter'] = tick_counter
    ..['tick_duration'] = tick_duration
    ..['tick_delay'] = tick_delay
    ..['x'] = x
    ..['y'] = y);
}

mixin GameParticle on HasGameData {
  bool active = false;

  void reset() => active = false;

  void activate() => active = true;

  // HasGameData

  @override
  void load_state(GameData data) => active = data['active'];

  @override
  GameData save_state(GameData data) => data..['active'] = active;
}
